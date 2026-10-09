import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

SheetRow columns = fieldMapping;

public function main() returns error? {
    do {
        string trimmedSpreadsheetId = spreadsheetId.trim();
        boolean isNewSpreadsheet = trimmedSpreadsheetId == "";
        SyncMode effectiveSyncMode = syncMode;
        
        string soqlQuery = check buildSoqlQuery();
        log:printInfo("Executing SOQL query: " + soqlQuery);
        
        stream<Lead, error?> leadStream = check salesforceClient->query(soqlQuery);
        
        SheetRow[] leadValues = check from Lead lead in leadStream 
                                      select check mapLeadToRow(lead);
        
        if leadValues.length() <= 0 {
            log:printWarn("No leads found matching the query criteria.");
            return;
        }
        
        log:printInfo(string `Found ${leadValues.length()} lead(s) to export.`);
        
        if isNewSpreadsheet && effectiveSyncMode == UPSERT_BY_EMAIL {
            return error("UPSERT_BY_EMAIL mode requires an existing spreadsheet (spreadsheetId must be provided). This mode updates existing leads by email and cannot work with a new spreadsheet. Use APPEND or FULL_REPLACE mode for new spreadsheets.");
        }
        
        string workingSpreadsheetId;
        string targetSheetName = tabName.trim() == "" ? "Leads" : tabName.trim();
        
        if trimmedSpreadsheetId != "" {
            workingSpreadsheetId = trimmedSpreadsheetId;
            log:printInfo("Using existing spreadsheet with ID: " + workingSpreadsheetId);
        } else {
            string currentTimeStamp = check getFormattedCurrentTimeStamp();
            string spreadSheetName = string `Salesforce Leads ${currentTimeStamp}`;
            sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(spreadSheetName);
            log:printInfo("Spreadsheet created with name: " + spreadSheetName);
            workingSpreadsheetId = spreadsheet.spreadsheetId;
        }
        
        if splitBy != "" {
            check syncLeadsSplit(workingSpreadsheetId, targetSheetName, leadValues, effectiveSyncMode, isNewSpreadsheet);
        } else {
            check syncLeadsByMode(workingSpreadsheetId, targetSheetName, leadValues, effectiveSyncMode, isNewSpreadsheet);
        }
        
        log:printInfo(string `${leadValues.length()} ${leadValues.length() == 1 ? "lead" : "leads"} synced to the spreadsheet successfully using ${effectiveSyncMode} mode.`);
        
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

function appendLeads(string spreadsheetId, string sheetName, SheetRow[] leadValues, boolean isNewSpreadsheet) returns error? {
    string effectiveSheetName = sheetName.trim() == "" ? "Leads" : sheetName.trim();
    
    sheets:Sheet targetSheet;
    string targetSheetName;
    boolean includeHeaders = false;
    
    if isNewSpreadsheet {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet defaultSheet = spreadsheet.sheets[0];
        
        string currentSheetName = defaultSheet.properties.title;
        
        log:printInfo(string `New spreadsheet created. Default sheet name: "${currentSheetName}", Target sheet name: "${effectiveSheetName}"`);
        
        if currentSheetName == "" || currentSheetName != effectiveSheetName {
            string nameToUse = currentSheetName == "" ? "Sheet1" : currentSheetName;
            _ = check sheetsClient->renameSheet(spreadsheetId, nameToUse, effectiveSheetName);
            log:printInfo(string `Renamed default sheet from "${nameToUse}" to: ${effectiveSheetName}`);
        } else {
            log:printInfo(string `Sheet already has the correct name: ${effectiveSheetName}`);
        }
        
        sheets:Spreadsheet updatedSpreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        targetSheet = updatedSpreadsheet.sheets[0];
        targetSheetName = targetSheet.properties.title;
        
        includeHeaders = true;
    } else {
        targetSheet = check getOrCreateSheet(spreadsheetId, effectiveSheetName);
        targetSheetName = targetSheet.properties.title;
        
        boolean isEmpty = check isSheetEmpty(spreadsheetId, targetSheetName);
        includeHeaders = isEmpty;
        
        log:printInfo(string `Appending to existing sheet: ${targetSheetName}`);
    }
    
    SheetRow[] dataToAppend = includeHeaders ? [columns, ...leadValues] : leadValues;
    
    _ = check sheetsClient->appendValues(spreadsheetId, dataToAppend, {sheetName: targetSheetName});
    
    if includeHeaders {
        check applySheetFormatting(spreadsheetId, targetSheet.properties.sheetId);
    }
}

function fullReplaceLeads(string spreadsheetId, string sheetName, SheetRow[] leadValues, boolean isNewSpreadsheet) returns error? {
    string effectiveSheetName = sheetName.trim() == "" ? "Leads" : sheetName.trim();
    
    SheetRow[] allValues = [columns, ...leadValues];
    
    if isNewSpreadsheet {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet defaultSheet = spreadsheet.sheets[0];
        
        string currentSheetName = defaultSheet.properties.title;
        string nameToUse = currentSheetName == "" ? "Sheet1" : currentSheetName;
        _ = check sheetsClient->renameSheet(spreadsheetId, nameToUse, effectiveSheetName);
        log:printInfo(string `Renamed default sheet to: ${effectiveSheetName}`);
        
        sheets:Spreadsheet updatedSpreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet targetSheet = updatedSpreadsheet.sheets[0];
        
        _ = check sheetsClient->appendValues(spreadsheetId, allValues, {sheetName: targetSheet.properties.title});
        
        check applySheetFormatting(spreadsheetId, targetSheet.properties.sheetId);
    } else {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        
        log:printInfo(string `Replacing all ${spreadsheet.sheets.length()} existing sheet(s) in the spreadsheet.`);
        
        string currentTimeStamp = check getFormattedCurrentTimeStamp();
        string tempSheetName = string `${effectiveSheetName}_temp_${currentTimeStamp}`;
        sheets:Sheet tempSheet = check sheetsClient->addSheet(spreadsheetId, tempSheetName);
        
        _ = check sheetsClient->appendValues(spreadsheetId, allValues, {sheetName: tempSheet.properties.title});
        
        check applySheetFormatting(spreadsheetId, tempSheet.properties.sheetId);
        
        do {
            foreach sheets:Sheet sheet in spreadsheet.sheets {
                _ = check sheetsClient->removeSheet(spreadsheetId, sheet.properties.sheetId);
            }
            
            _ = check sheetsClient->renameSheet(spreadsheetId, tempSheet.properties.title, effectiveSheetName);
        } on fail error e {
            error? cleanupError = sheetsClient->removeSheet(spreadsheetId, tempSheet.properties.sheetId);
            if cleanupError is error {
                log:printError(string `Failed to cleanup temp sheet after error: ${cleanupError.message()}`);
            }
            return e;
        }
        
        log:printInfo(string `All existing sheets replaced. Created fresh sheet: ${effectiveSheetName}`);
    }
}

function upsertLeadsByEmail(string spreadsheetId, string sheetName, SheetRow[] leadValues) returns error? {
    string effectiveSheetName = sheetName.trim() == "" ? "Leads" : sheetName.trim();
    
    sheets:Sheet sheet = check getOrCreateSheet(spreadsheetId, effectiveSheetName);
    
    boolean isEmpty = check isSheetEmpty(spreadsheetId, sheet.properties.title);
    
    if isEmpty {
        SheetRow[] dataToAppend = [columns, ...leadValues];
        _ = check sheetsClient->appendValues(spreadsheetId, dataToAppend, {sheetName: sheet.properties.title});
        check applySheetFormatting(spreadsheetId, sheet.properties.sheetId);
        log:printInfo("Sheet is empty. Added headers and all leads.");
        return;
    }
    
    int columnCount = fieldMapping.length();
    string endColumn = check columnIndexToLetter(columnCount);
    sheets:Range existingRange = check sheetsClient->getRange(spreadsheetId, sheet.properties.title, a1Notation = string `A:${endColumn}`);
    (int|string|decimal)[][] existingValues = existingRange.values;
    
    if existingValues.length() <= 1 {
        _ = check sheetsClient->appendValues(spreadsheetId, leadValues, {sheetName: sheet.properties.title});
        log:printInfo("Only headers found. Appended all leads.");
        return;
    }
    
    int emailColumnIndex = getFieldIndex("Email");
    
    if emailColumnIndex == -1 {
        log:printWarn("Email field not found in fieldMapping. Falling back to APPEND mode.");
        _ = check sheetsClient->appendValues(spreadsheetId, leadValues, {sheetName: sheet.properties.title});
        return;
    }
    
    SheetRow[] existingRows = [];
    map<int> emailToRowIndex = {};
    
    int rowIndex = 0;
    foreach (int|string|decimal)[] row in existingValues.slice(1) {
        SheetRow convertedRow = [];
        foreach (int|string|decimal) cell in row {
            convertedRow.push(cell);
        }
        
        if row.length() > emailColumnIndex {
            (int|string|decimal) emailValue = row[emailColumnIndex];
            string email = emailValue.toString();
            if email != "" {
                emailToRowIndex[email] = rowIndex;
            }
        }
        
        existingRows.push(convertedRow);
        rowIndex = rowIndex + 1;
    }
    
    SheetRow[] newLeads = [];
    int updatedCount = 0;
    
    foreach SheetRow leadRow in leadValues {
        if leadRow.length() > emailColumnIndex {
            int|string|decimal|boolean|float emailValue = leadRow[emailColumnIndex];
            string email = emailValue.toString();
            
            if email != "" && emailToRowIndex.hasKey(email) {
                int existingRowIndex = emailToRowIndex.get(email);
                existingRows[existingRowIndex] = leadRow;
                updatedCount = updatedCount + 1;
            } else {
                newLeads.push(leadRow);
            }
        } else {
            newLeads.push(leadRow);
        }
    }
    
    SheetRow[] allData = [columns];
    foreach SheetRow row in existingRows {
        allData.push(row);
    }
    
    foreach SheetRow newLead in newLeads {
        allData.push(newLead);
    }
    
    string tempSheetName = string `${sheet.properties.title}_temp_${check getFormattedCurrentTimeStamp()}`;
    sheets:Sheet tempSheet = check sheetsClient->addSheet(spreadsheetId, tempSheetName);
    
    _ = check sheetsClient->appendValues(spreadsheetId, allData, {sheetName: tempSheet.properties.title});
    
    _ = check sheetsClient->clearRange(spreadsheetId, sheet.properties.title, a1Notation = string `A:${endColumn}`);
    
    sheets:Range tempRange = check sheetsClient->getRange(spreadsheetId, tempSheet.properties.title, a1Notation = string `A:${endColumn}`);
    _ = check sheetsClient->appendValues(spreadsheetId, tempRange.values, {sheetName: sheet.properties.title});
    
    _ = check sheetsClient->removeSheet(spreadsheetId, tempSheet.properties.sheetId);
    
    check applySheetFormatting(spreadsheetId, sheet.properties.sheetId);
    
    log:printInfo(string `UPSERT completed: ${updatedCount} lead(s) updated, ${newLeads.length()} new lead(s) added.`);
}

function getOrCreateSheet(string spreadsheetId, string sheetName) returns sheets:Sheet|error {
    sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
    
    foreach sheets:Sheet sheet in spreadsheet.sheets {
        if sheet.properties.title == sheetName {
            return sheet;
        }
    }
    
    return check sheetsClient->addSheet(spreadsheetId, sheetName);
}

function isSheetEmpty(string spreadsheetId, string sheetName) returns boolean|error {
    sheets:Range|error result = sheetsClient->getRange(spreadsheetId, sheetName, "A1:A1");
    
    if result is error {
        return result;
    }
    
    sheets:Range range = result;
    if range.values.length() == 0 {
        return true;
    }
    
    (int|string|decimal)[] firstRow = range.values[0];
    if firstRow.length() == 0 {
        return true;
    }
    
    return false;
}

function getFieldIndex(string targetField) returns int {
    int index = 0;
    foreach string fieldName in fieldMapping {
        if fieldName.toLowerAscii() == targetField.toLowerAscii() {
            return index;
        }
        index = index + 1;
    }
    return -1;
}

function syncLeadsSplit(string spreadsheetId, string baseSheetName, SheetRow[] leadValues, SyncMode mode, boolean isNewSpreadsheet) returns error? {
    int splitFieldIndex = getFieldIndex(splitBy);
    
    if splitFieldIndex == -1 {
        log:printWarn(string `Split field "${splitBy}" not found in fieldMapping. Falling back to single sheet sync.`);
        check syncLeadsByMode(spreadsheetId, baseSheetName, leadValues, mode, isNewSpreadsheet);
        return;
    }
    
    map<SheetRow[]> groupedLeads = {};
    
    foreach SheetRow leadRow in leadValues {
        if leadRow.length() > splitFieldIndex {
            int|string|decimal|boolean|float fieldValue = leadRow[splitFieldIndex];
            string groupKey = fieldValue.toString();
            
            if groupKey == "" {
                groupKey = "Unknown";
            }
            
            if !groupedLeads.hasKey(groupKey) {
                groupedLeads[groupKey] = [];
            }
            
            groupedLeads.get(groupKey).push(leadRow);
        }
    }
    
    boolean isFirstGroup = true;
    foreach string groupKey in groupedLeads.keys() {
        SheetRow[] groupLeads = groupedLeads.get(groupKey);
        string sheetNameWithGroup = string `${baseSheetName} - ${groupKey}`;
        
        log:printInfo(string `Syncing ${groupLeads.length()} lead(s) to sheet: ${sheetNameWithGroup}`);
        
        check syncLeadsByMode(spreadsheetId, sheetNameWithGroup, groupLeads, mode, isNewSpreadsheet && isFirstGroup);
        isFirstGroup = false;
    }
    
    log:printInfo(string `Split sync completed. Created/updated ${groupedLeads.keys().length()} sheet(s) based on ${splitBy}.`);
}

function syncLeadsByMode(string spreadsheetId, string sheetName, SheetRow[] leadValues, SyncMode mode, boolean isNewSpreadsheet) returns error? {
    match mode {
        APPEND => {
            check appendLeads(spreadsheetId, sheetName, leadValues, isNewSpreadsheet);
        }
        FULL_REPLACE => {
            check fullReplaceLeads(spreadsheetId, sheetName, leadValues, isNewSpreadsheet);
        }
        UPSERT_BY_EMAIL => {
            check upsertLeadsByEmail(spreadsheetId, sheetName, leadValues);
        }
    }
}

function applySheetFormatting(string spreadsheetId, int sheetId) returns error? {
    if !enableAutoFormat {
        return;
    }
    
    log:printInfo("Auto-formatting enabled. Headers will appear in first row (manual formatting recommended for bold/freeze).");
}

function columnIndexToLetter(int index) returns string|error {
    if index <= 0 {
        return error("Column index must be greater than 0");
    }
    
    if index > 702 {
        return error("Column index exceeds maximum supported value (702 = ZZ)");
    }
    
    if index <= 26 {
        return check string:fromCodePointInt(64 + index);
    }
    
    int firstLetter = (index - 1) / 26;
    int secondLetter = (index - 1) % 26 + 1;
    
    string first = check string:fromCodePointInt(64 + firstLetter);
    string second = check string:fromCodePointInt(64 + secondLetter);
    
    return string `${first}${second}`;
}
