import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

SheetRow columns = fieldMapping;

public function main() returns error? {
    do {
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
        
        string workingSpreadsheetId;
        string targetSheetName = tabName;
        string trimmedSpreadsheetId = spreadsheetId.trim();
        
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
        
        string effectiveSyncMode = syncMode.trim() == "" ? "APPEND" : syncMode;
        
        boolean isNewSpreadsheet = trimmedSpreadsheetId == "";
        
        if isNewSpreadsheet && effectiveSyncMode == "UPSERT_BY_EMAIL" {
            return error("UPSERT_BY_EMAIL mode requires an existing spreadsheet (spreadsheetId must be provided). This mode updates existing leads by email and cannot work with a new spreadsheet. Use APPEND or FULL_REPLACE mode for new spreadsheets.");
        }
        
        if splitBy != "" {
            check syncLeadsSplit(workingSpreadsheetId, targetSheetName, leadValues, effectiveSyncMode, isNewSpreadsheet);
        } else {
            if effectiveSyncMode == "APPEND" {
                check appendLeads(workingSpreadsheetId, targetSheetName, leadValues, isNewSpreadsheet);
            } else if effectiveSyncMode == "FULL_REPLACE" {
                check fullReplaceLeads(workingSpreadsheetId, targetSheetName, leadValues, isNewSpreadsheet);
            } else if effectiveSyncMode == "UPSERT_BY_EMAIL" {
                check upsertLeadsByEmail(workingSpreadsheetId, targetSheetName, leadValues);
            } else {
                return error(string `Invalid syncMode: ${effectiveSyncMode}. Must be "APPEND", "FULL_REPLACE", or "UPSERT_BY_EMAIL"`);
            }
        }
        
        log:printInfo(string `${leadValues.length()} ${leadValues.length() == 1 ? "lead" : "leads"} synced to the spreadsheet successfully using ${effectiveSyncMode} mode.`);
        
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

function appendLeads(string spreadsheetId, string sheetName, SheetRow[] leadValues, boolean isNewSpreadsheet) returns error? {
    sheets:Sheet targetSheet;
    string newSheetName;
    
    if isNewSpreadsheet {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet defaultSheet = spreadsheet.sheets[0];
        
        string currentTimeStamp = check getFormattedCurrentTimeStamp();
        newSheetName = string `${sheetName} ${currentTimeStamp}`;
        
        string currentSheetName = defaultSheet.properties.title;
        _ = check sheetsClient->renameSheet(spreadsheetId, currentSheetName, newSheetName);
        log:printInfo(string `Renamed default sheet to: ${newSheetName}`);
        
        sheets:Spreadsheet updatedSpreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        targetSheet = updatedSpreadsheet.sheets[0];
    } else {
        string currentTimeStamp = check getFormattedCurrentTimeStamp();
        newSheetName = string `${sheetName} ${currentTimeStamp}`;
        
        targetSheet = check sheetsClient->addSheet(spreadsheetId, newSheetName);
        log:printInfo(string `Created new sheet: ${newSheetName}`);
    }
    
    SheetRow[] dataToAppend = [columns, ...leadValues];
    
    _ = check sheetsClient->appendValues(spreadsheetId, dataToAppend, {sheetName: targetSheet.properties.title});
    
    check applySheetFormatting(spreadsheetId, targetSheet.properties.sheetId);
}

function fullReplaceLeads(string spreadsheetId, string sheetName, SheetRow[] leadValues, boolean isNewSpreadsheet) returns error? {
    SheetRow[] allValues = [columns, ...leadValues];
    
    if isNewSpreadsheet {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet defaultSheet = spreadsheet.sheets[0];
        
        string currentSheetName = defaultSheet.properties.title;
        _ = check sheetsClient->renameSheet(spreadsheetId, currentSheetName, sheetName);
        log:printInfo(string `Renamed default sheet to: ${sheetName}`);
        
        sheets:Spreadsheet updatedSpreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        sheets:Sheet targetSheet = updatedSpreadsheet.sheets[0];
        
        _ = check sheetsClient->appendValues(spreadsheetId, allValues, {sheetName: targetSheet.properties.title});
        
        check applySheetFormatting(spreadsheetId, targetSheet.properties.sheetId);
    } else {
        sheets:Spreadsheet spreadsheet = check sheetsClient->openSpreadsheetById(spreadsheetId);
        
        log:printInfo(string `Deleting all ${spreadsheet.sheets.length()} existing sheet(s) from the spreadsheet.`);
        
        sheets:Sheet tempSheet = check sheetsClient->addSheet(spreadsheetId, "TempSheet_DeleteMe");
        
        foreach sheets:Sheet sheet in spreadsheet.sheets {
            _ = check sheetsClient->removeSheet(spreadsheetId, sheet.properties.sheetId);
        }
        
        sheets:Sheet newSheet = check sheetsClient->addSheet(spreadsheetId, sheetName);
        
        _ = check sheetsClient->appendValues(spreadsheetId, allValues, {sheetName: newSheet.properties.title});
        
        check applySheetFormatting(spreadsheetId, newSheet.properties.sheetId);
        
        _ = check sheetsClient->removeSheet(spreadsheetId, tempSheet.properties.sheetId);
        
        log:printInfo(string `All existing sheets deleted. Created fresh sheet: ${sheetName}`);
    }
}

function upsertLeadsByEmail(string spreadsheetId, string sheetName, SheetRow[] leadValues) returns error? {
    sheets:Sheet sheet = check getOrCreateSheet(spreadsheetId, sheetName);
    
    boolean isEmpty = check isSheetEmpty(spreadsheetId, sheet.properties.title);
    
    if isEmpty {
        SheetRow[] dataToAppend = [columns, ...leadValues];
        _ = check sheetsClient->appendValues(spreadsheetId, dataToAppend, {sheetName: sheet.properties.title});
        check applySheetFormatting(spreadsheetId, sheet.properties.sheetId);
        log:printInfo("Sheet is empty. Added headers and all leads.");
        return;
    }
    
    sheets:Range existingRange = check sheetsClient->getRange(spreadsheetId, sheet.properties.title, a1Notation = "A:Z");
    (int|string|decimal)[][] existingValues = existingRange.values;
    
    if existingValues.length() <= 1 {
        _ = check sheetsClient->appendValues(spreadsheetId, leadValues, {sheetName: sheet.properties.title});
        log:printInfo("Only headers found. Appended all leads.");
        return;
    }
    
    int emailColumnIndex = getEmailColumnIndex();
    
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
    
    _ = check sheetsClient->clearRange(spreadsheetId, sheet.properties.title, a1Notation = "A:Z");
    _ = check sheetsClient->appendValues(spreadsheetId, allData, {sheetName: sheet.properties.title});
    
    check applySheetFormatting(spreadsheetId, sheet.properties.sheetId);
    
    if newLeads.length() > 0 {
        _ = check sheetsClient->appendValues(spreadsheetId, newLeads, {sheetName: sheet.properties.title});
    }
    
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

function getEmailColumnIndex() returns int {
    int index = 0;
    foreach string fieldName in fieldMapping {
        if fieldName == "Email" {
            return index;
        }
        index = index + 1;
    }
    return -1;
}

function syncLeadsSplit(string spreadsheetId, string baseSheetName, SheetRow[] leadValues, string mode, boolean isNewSpreadsheet) returns error? {
    int splitFieldIndex = getSplitFieldIndex();
    
    if splitFieldIndex == -1 {
        log:printWarn(string `Split field "${splitBy}" not found in fieldMapping. Falling back to single sheet sync.`);
        if mode == "APPEND" {
            check appendLeads(spreadsheetId, baseSheetName, leadValues, isNewSpreadsheet);
        } else if mode == "FULL_REPLACE" {
            check fullReplaceLeads(spreadsheetId, baseSheetName, leadValues, isNewSpreadsheet);
        } else if mode == "UPSERT_BY_EMAIL" {
            check upsertLeadsByEmail(spreadsheetId, baseSheetName, leadValues);
        }
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
            
            SheetRow[] existingGroup = groupedLeads.get(groupKey);
            existingGroup.push(leadRow);
            groupedLeads[groupKey] = existingGroup;
        }
    }
    
    boolean isFirstGroup = true;
    foreach string groupKey in groupedLeads.keys() {
        SheetRow[] groupLeads = groupedLeads.get(groupKey);
        string sheetNameWithGroup = string `${baseSheetName} - ${groupKey}`;
        
        log:printInfo(string `Syncing ${groupLeads.length()} lead(s) to sheet: ${sheetNameWithGroup}`);
        
        if mode == "APPEND" {
            check appendLeads(spreadsheetId, sheetNameWithGroup, groupLeads, isNewSpreadsheet && isFirstGroup);
            isFirstGroup = false;
        } else if mode == "FULL_REPLACE" {
            check fullReplaceLeads(spreadsheetId, sheetNameWithGroup, groupLeads, isNewSpreadsheet && isFirstGroup);
            isFirstGroup = false;
        } else if mode == "UPSERT_BY_EMAIL" {
            check upsertLeadsByEmail(spreadsheetId, sheetNameWithGroup, groupLeads);
        }
    }
    
    log:printInfo(string `Split sync completed. Created/updated ${groupedLeads.keys().length()} sheet(s) based on ${splitBy}.`);
}

function getSplitFieldIndex() returns int {
    int index = 0;
    foreach string fieldName in fieldMapping {
        if fieldName == splitBy {
            return index;
        }
        index = index + 1;
    }
    return -1;
}

function applySheetFormatting(string spreadsheetId, int sheetId) returns error? {
    if !enableAutoFormat {
        return;
    }
    
    log:printInfo("Auto-formatting enabled. Headers will appear in first row (manual formatting recommended for bold/freeze).");
}
