import ballerina/io;
import ballerinax/hubspot.crm.obj.contacts as hubspotcontacts;
import ballerinax/googleapis.sheets;

// Validate external API access with current configuration.
function validateExternalConnections() returns error? {
    sheets:Spreadsheet _ = check sheetsClient->openSpreadsheetById(spreadsheetId);
    hubspotcontacts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging _ = check fetchContactsPage(());
    return;
}

// Check if the sheet is empty and insert headers if needed
function ensureHeaderRow(string targetSheet) returns error? {
    check ensureSheetExists(targetSheet);

    sheets:Range|error rangeResult = sheetsClient->getRange(spreadsheetId, targetSheet, "A1:Z1");

    if rangeResult is error {
        return rangeResult;
    }

    sheets:Range rangeData = rangeResult;

    if rangeData.values.length() == 0 {
        io:println(string `---- Sheet '${targetSheet}' is empty. Inserting headers`);
        check insertHeaderRow(targetSheet);
    } else {
        io:println(string `---- Header exists in '${targetSheet}'`);
    }
}

// Ensure worksheet exists. If missing, create it automatically.
function ensureSheetExists(string targetSheet) returns error? {
    sheets:Sheet|error existingSheet = sheetsClient->getSheetByName(spreadsheetId, targetSheet);
    if existingSheet is sheets:Sheet {
        return;
    }

    sheets:Sheet|error addedSheet = sheetsClient->addSheet(spreadsheetId, targetSheet);
    if addedSheet is error {
        // Handle concurrent creation or transient lookup failures by re-checking.
        sheets:Sheet|error sheetAfterRetry = sheetsClient->getSheetByName(spreadsheetId, targetSheet);
        if sheetAfterRetry is sheets:Sheet {
            return;
        }
        return addedSheet;
    }

    io:println(string `---- Created missing sheet '${targetSheet}'`);
}

// Insert header row
function insertHeaderRow(string targetSheet) returns error? {

    (string|int|decimal)[] headers = [];

    foreach string fieldName in fields {
        headers.push(convertFieldToHeader(fieldName));
    }

    headers.push("Last Synced");

    check sheetsClient->appendRowToSheet(spreadsheetId, targetSheet, headers);

    io:println(string `---- Header inserted in '${targetSheet}'`);
}

// Convert field name to header
function convertFieldToHeader(string fieldName) returns string {

    match fieldName {
        "email" => {
            return "Email";
        }
        "firstname" => {
            return "First Name";
        }
        "lastname" => {
            return "Last Name";
        }
        "phone" => {
            return "Phone";
        }
        _ => {
            if fieldName.length() > 0 {
                return fieldName.substring(0,1).toUpperAscii() + fieldName.substring(1);
            }
            return fieldName;
        }
    }
}

// Fetch HubSpot contacts with optional incremental sync
function fetchHubSpotContacts(string lastSyncTime) returns Contact[]|error {

    Contact[] allContacts = [];
    string? afterCursor = ();
    
    boolean isIncrementalSync = lastSyncTime != "";
    boolean hasContactFilter = contactFilterProperty.trim() != "" && contactFilterValue.trim() != "";
    
    if isIncrementalSync {
        io:println(string `---- Incremental sync from ${lastSyncTime} (maxRows = ${maxRows})`);
    } else {
        io:println("---- Full sync mode (maxRows ignored)");
    }

    if hasContactFilter {
        io:println(string `---- Contact filter: ${contactFilterProperty} = ${contactFilterValue}`);
    }

    while true {

        hubspotcontacts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response =
            check fetchContactsPage(afterCursor);

        foreach var hubspotContact in response.results {

            record {|string?...;|} props = hubspotContact.properties;

            Contact contact = {
                id: hubspotContact.id,
                properties: {
                    email: getPropertyValue(props,"email"),
                    firstname: getPropertyValue(props,"firstname"),
                    lastname: getPropertyValue(props,"lastname"),
                    phone: getPropertyValue(props,"phone"),
                    lifecyclestage: getPropertyValue(props,"lifecyclestage")
                },
                createdAt: hubspotContact.createdAt,
                updatedAt: hubspotContact.updatedAt,
                archived: hubspotContact.archived ?: false
            };

            // Apply optional contact property filter.
            if hasContactFilter {
                string filterPropertyValue = getPropertyValue(props, contactFilterProperty).trim().toLowerAscii();
                if filterPropertyValue != contactFilterValue.trim().toLowerAscii() {
                    continue;
                }
            }
            
            // Filter contacts based on last sync timestamp
            if isIncrementalSync {
                if isNewerThan(contact.updatedAt, lastSyncTime) {
                    allContacts.push(contact);
                }
            } else {
                allContacts.push(contact);
            }
        }

        string? nextAfter = response.paging?.next?.after;

        if nextAfter is string {
            afterCursor = nextAfter;
        } else {
            break;
        }
    }

    io:println(string `---- Contacts selected for export: ${allContacts.length()}`);

    // Sort by updatedAt ascending so oldest unprocessed contacts are handled first.
    // This ensures the checkpoint advances steadily when maxRows is set.
    Contact[] sortedContacts = from Contact c in allContacts
        order by c.updatedAt ascending
        select c;

    return sortedContacts;
}

// Extract property safely
function getPropertyValue(record {|string?...;|} properties, string key) returns string {
    return <string?>properties.get(key) ?: "";
}

// Contact property getter
function getContactPropertyValue(ContactProperties properties, string key) returns string {

    match key {
        "email" => {
            return properties.email ?: "";
        }
        "firstname" => {
            return properties.firstname ?: "";
        }
        "lastname" => {
            return properties.lastname ?: "";
        }
        "phone" => {
            return properties.phone ?: "";
        }
        "lifecyclestage" => {
            return properties.lifecyclestage ?: "";
        }
        _ => {
            return "";
        }
    }
}

// Fetch contacts page
function fetchContactsPage(string? afterCursor)
returns hubspotcontacts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error {

    string[] requestProperties = getHubSpotRequestProperties();

    if afterCursor is string {
        return hubspotClient->/.get(after = afterCursor, properties = requestProperties, 'limit = 100);
    }

    return hubspotClient->/.get(properties = requestProperties, 'limit = 100);
}

function getHubSpotRequestProperties() returns string[] {
    string[] requestProperties = [];

    foreach string fieldName in fields {
        requestProperties.push(fieldName);
    }

    string filterProperty = contactFilterProperty.trim();
    if filterProperty != "" {
        boolean alreadyIncluded = false;
        foreach string fieldName in requestProperties {
            if fieldName == filterProperty {
                alreadyIncluded = true;
                break;
            }
        }

        if !alreadyIncluded {
            requestProperties.push(filterProperty);
        }
    }

    boolean hasLifecycleStage = false;
    foreach string fieldName in requestProperties {
        if fieldName == "lifecyclestage" {
            hasLifecycleStage = true;
            break;
        }
    }

    if !hasLifecycleStage {
        requestProperties.push("lifecyclestage");
    }

    return requestProperties;
}

// Build email → row map
function buildEmailRowMap(string targetSheet) returns map<int>|error {

    map<int> emailRowMap = {};

    sheets:Range|error result =
        sheetsClient->getRange(spreadsheetId, targetSheet, "A:A");

    if result is error {
        io:println(string `---- No existing rows in '${targetSheet}'`);
        return emailRowMap;
    }

    sheets:Range rangeData = result;

    int rowIndex = 1;

    foreach (int|string|decimal)[] row in rangeData.values {

        if rowIndex > 1 && row.length() > 0 {

            string email =
                row[0].toString().trim().toLowerAscii();

            if email != "" {
                emailRowMap[email] = rowIndex;
            }
        }

        rowIndex += 1;
    }

    io:println(string `---- Existing contacts in '${targetSheet}': ${emailRowMap.length()}`);

    return emailRowMap;
}

// Update row
function updateSheetRow(string targetSheet, int rowNumber, (string|int|decimal)[] rowData) returns error? {

    string endColumn = getColumnLetter(rowData.length());

    string range =
        string `A${rowNumber}:${endColumn}${rowNumber}`;

    sheets:Range updateRange = {
        a1Notation: range,
        values: [rowData]
    };

    check sheetsClient->setRange(spreadsheetId, targetSheet, updateRange);
}

function getTargetSheetName(Contact contact) returns string {
    string lifecycleStage = getContactPropertyValue(contact.properties, "lifecyclestage").trim().toLowerAscii();

    match lifecycleStage {
        "subscriber" => { return subscriberSheetName; }
        "lead" => { return leadSheetName; }
        "marketingqualifiedlead" => { return marketingqualifiedleadSheetName; }
        "salesqualifiedlead" => { return salesqualifiedleadSheetName; }
        "opportunity" => { return opportunitySheetName; }
        "customer" => { return customerSheetName; }
        "evangelist" => { return evangelistSheetName; }
        "other" => { return otherSheetName; }
    }

    return defaultSheetName;
}

// Column index → letter
function getColumnLetter(int columnNumber) returns string {

    string[] alphabet = [
        "A","B","C","D","E","F","G","H","I","J","K","L","M",
        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    ];

    string columnLetter = "";
    int number = columnNumber;

    while number > 0 {

        int remainder = (number - 1) % 26;

        columnLetter =
            string `${alphabet[remainder]}${columnLetter}`;

        number = (number - 1) / 26;
    }

    return columnLetter;
}

// Clear all data rows in a sheet (keeps header row)
function clearSheetData(string targetSheet) returns error? {
    sheets:Range|error result = sheetsClient->getRange(spreadsheetId, targetSheet, "A:Z");
    if result is error {
        return;
    }
    int totalRows = result.values.length();
    if totalRows <= 1 {
        return;
    }
    // Clear from row 2 downward
    string clearRange = string `A2:Z${totalRows}`;
    check sheetsClient->clearRange(spreadsheetId, targetSheet, clearRange);
    io:println(string `---- Cleared ${totalRows - 1} data rows from '${targetSheet}'`);
}

// Export contacts to Google Sheet using the configured sync mode
function exportContactsToSheet(Contact[] contacts, string lastSyncTimestamp, boolean isFullSync) returns string|error {

    string mode = syncMode.trim().toLowerAscii();
    io:println(string `---- Preparing sheet export (mode: ${mode})`);

    // For replace mode: clear all target sheets before writing
    if mode == "replace" {
        map<boolean> clearedSheets = {};
        foreach Contact contact in contacts {
            string targetSheet = getTargetSheetName(contact);
            if !clearedSheets.hasKey(targetSheet) {
                check ensureHeaderRow(targetSheet);
                check clearSheetData(targetSheet);
                clearedSheets[targetSheet] = true;
            }
        }
    }

    map<map<int>> emailRowMapBySheet = {};

    int insertCount = 0;
    int updateCount = 0;
    int errorCount = 0;

    string latestTimestamp = lastSyncTimestamp;
    int processedCount = 0;
    boolean limitReached = false;

    foreach Contact contact in contacts {

        // Apply max row limit only during incremental sync runs.
        if !isFullSync && maxRows > 0 {
            if processedCount >= maxRows {
                io:println("Max row limit reached. Stopping export.");
                limitReached = true;
                break;
            }
        }

        ContactProperties props = contact.properties;
        string targetSheet = getTargetSheetName(contact);

        string email =
            getContactPropertyValue(props, "email")
            .trim()
            .toLowerAscii();

        if email == "" {
            io:println(string `---- Skipping ${contact.id}: missing email`);
            errorCount += 1;
            continue;
        }

        (string|int|decimal)[] rowData = [];
        foreach string fieldName in fields {
            rowData.push(getContactPropertyValue(props, fieldName));
        }
        rowData.push(getCurrentTimestamp());

        boolean writeSucceeded = false;

        if mode == "append" || mode == "replace" {
            // append and replace both just insert a new row
            check ensureHeaderRow(targetSheet);
            error? result = sheetsClient->appendRowToSheet(spreadsheetId, targetSheet, rowData);
            if result is error {
                io:println(string `---- Insert failed for contact ${contact.id} in '${targetSheet}'`);
                errorCount += 1;
            } else {
                insertCount += 1;
                writeSucceeded = true;
            }
        } else {
            // Default: upsert — update if email exists, insert if not
            map<int>? existingSheetMap = emailRowMapBySheet[targetSheet];
            map<int> emailRowMap;
            if existingSheetMap is map<int> {
                emailRowMap = existingSheetMap;
            } else {
                check ensureHeaderRow(targetSheet);
                emailRowMap = check buildEmailRowMap(targetSheet);
                emailRowMapBySheet[targetSheet] = emailRowMap;
            }

            int? existingRow = emailRowMap[email];
            if existingRow is int {
                error? result = updateSheetRow(targetSheet, existingRow, rowData);
                if result is error {
                    io:println(string `---- Update failed for contact ${contact.id} in '${targetSheet}'`);
                    errorCount += 1;
                } else {
                    updateCount += 1;
                    writeSucceeded = true;
                }
            } else {
                error? result = sheetsClient->appendRowToSheet(spreadsheetId, targetSheet, rowData);
                if result is error {
                    io:println(string `---- Insert failed for contact ${contact.id} in '${targetSheet}'`);
                    errorCount += 1;
                } else {
                    insertCount += 1;
                    writeSucceeded = true;
                    emailRowMap[email] = emailRowMap.length() + 2;
                }
            }
        }

        if writeSucceeded {
            processedCount += 1;
        }

        if writeSucceeded && (latestTimestamp == "" || isNewerThan(contact.updatedAt, latestTimestamp)) {
            latestTimestamp = contact.updatedAt;
        }
    }

    string limitInfo = limitReached ? " (limit reached)" : "";
    io:println(
        string `---- Export summary: inserted ${insertCount}, updated ${updateCount}, failed ${errorCount}${limitInfo}`
    );

    return latestTimestamp;
}