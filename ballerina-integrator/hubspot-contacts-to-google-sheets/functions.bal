import ballerina/log;
import ballerina/lang.runtime;
import ballerinax/hubspot.crm.obj.contacts as hubspotcontacts;
import ballerinax/googleapis.sheets;

const int MAX_WRITE_RETRY_ATTEMPTS = 3;
const decimal INITIAL_WRITE_BACKOFF_SECONDS = 2d;

// Validate external API access with current configuration.
function validateExternalConnections() returns error? {
    sheets:Spreadsheet _ = check sheetsClient->openSpreadsheetById(spreadsheetId);
    hubspotcontacts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging _ = check fetchContactsPage(());
}

// Check if the sheet is empty and insert headers if needed
function ensureHeaderRow(string targetSheet) returns error? {
    check ensureSheetExists(targetSheet);

    sheets:Range rangeData = check sheetsClient->getRange(spreadsheetId, targetSheet, "A1:Z1");

    if rangeData.values.length() == 0 {
        log:printInfo(string `---- Sheet '${targetSheet}' is empty. Inserting headers`);
        check insertHeaderRow(targetSheet);
    } else {
        log:printInfo(string `---- Header exists in '${targetSheet}'`);
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
        sheets:Sheet sheetAfterRetry = check sheetsClient->getSheetByName(spreadsheetId, targetSheet);
    }

    log:printInfo(string `---- Created missing sheet '${targetSheet}'`);
}

// Insert header row
function insertHeaderRow(string targetSheet) returns error? {

    // email is always first — it is the upsert key and must map to Column A.
    (string|int|decimal)[] headers = [convertFieldToHeader("email")];

    foreach string fieldName in fields {
        if fieldName != "email" {
            headers.push(convertFieldToHeader(fieldName));
        }
    }

    headers.push("Last Synced");

    check sheetsClient->appendRowToSheet(spreadsheetId, targetSheet, headers);

    log:printInfo(string `---- Header inserted in '${targetSheet}'`);
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
        log:printInfo(string `---- Incremental sync from ${lastSyncTime} (maxRows = ${maxRows})`);
    } else {
        log:printInfo("---- Full sync mode (maxRows ignored)");
    }

    if hasContactFilter {
        log:printInfo(string `---- Contact filter: ${contactFilterProperty} = ${contactFilterValue}`);
    }

    while true {

        hubspotcontacts:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging response =
            check fetchContactsPage(afterCursor);

        foreach var hubspotContact in response.results {

            record {|string?...;|} props = hubspotContact.properties;

            // Copy ALL fetched properties into an open ContactProperties record
            // so that custom fields configured in `fields` are never dropped.
            ContactProperties copiedProps = {};
            foreach var [k, v] in props.entries() {
                copiedProps[k] = v;
            }

            Contact contact = {
                id: hubspotContact.id,
                properties: copiedProps,
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

    log:printInfo(string `---- Contacts selected for export: ${allContacts.length()}`);

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

// Contact property getter — generic lookup so custom fields are supported.
function getContactPropertyValue(ContactProperties properties, string key) returns string {
    string? value = properties[key];
    return value ?: "";
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
    // email must always be first — it is the upsert key and maps to Column A.
    string[] requestProperties = ["email"];

    foreach string fieldName in fields {
        if fieldName != "email" {
            requestProperties.push(fieldName);
        }
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

    // `lifecyclestage` must always be fetched — it drives sheet routing.
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

// Build email → row map.
// Propagates read errors so the caller cannot silently treat a failed
// sheet read as an empty sheet (which would cause duplicate inserts).
// Build email → row map.
// Propagates read errors so the caller cannot silently treat a failed
// sheet read as an empty sheet (which would cause duplicate inserts).
// Returns a tuple of [emailRowMap, totalRowCount] where totalRowCount is the
// actual number of rows in the sheet (header + data), used by the caller to
// determine the correct row number for new inserts.
function buildEmailRowMap(string targetSheet) returns [map<int>, int]|error {

    map<int> emailRowMap = {};

    // Propagate the error — do NOT swallow it and return an empty map.
    // Returning {} on a read failure would make every upsert look like an
    // insert, silently creating duplicate rows.
    sheets:Range rangeData = check sheetsClient->getRange(spreadsheetId, targetSheet, "A:A");

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

    log:printInfo(string `---- Existing contacts in '${targetSheet}': ${emailRowMap.length()}`);

    // rangeData.values.length() is the total number of rows returned by the
    // Sheets API for column A (header + all data rows, including blank-email
    // rows that were skipped above).  The next new row goes at position
    // totalRowCount + 1.
    int totalRowCount = rangeData.values.length();

    return [emailRowMap, totalRowCount];
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

function isSheetsRateLimitError(error err) returns boolean {
    string errorText = err.toString();
    return errorText.includes("\"code\":429")
        || errorText.includes("RATE_LIMIT_EXCEEDED")
        || errorText.includes("RESOURCE_EXHAUSTED");
}

function appendSheetRowWithRetry(string targetSheet, (string|int|decimal)[] rowData, string contactId) returns error? {
    int attempt = 0;
    decimal backoff = INITIAL_WRITE_BACKOFF_SECONDS;

    while true {
        error? appendResult = sheetsClient->appendRowToSheet(spreadsheetId, targetSheet, rowData);
        if appendResult is () {
            return;
        }

        if !isSheetsRateLimitError(appendResult) || attempt >= MAX_WRITE_RETRY_ATTEMPTS {
            return appendResult;
        }

        attempt += 1;
        log:printError(string `---- Rate limit hit while inserting contact ${contactId} in '${targetSheet}'. Retrying in ${backoff}s (attempt ${attempt}/${MAX_WRITE_RETRY_ATTEMPTS})`);
        runtime:sleep(backoff);
        backoff *= 2d;
    }
}

function updateSheetRowWithRetry(string targetSheet, int rowNumber, (string|int|decimal)[] rowData, string contactId) returns error? {
    int attempt = 0;
    decimal backoff = INITIAL_WRITE_BACKOFF_SECONDS;

    while true {
        error? updateResult = updateSheetRow(targetSheet, rowNumber, rowData);
        if updateResult is () {
            return;
        }

        if !isSheetsRateLimitError(updateResult) || attempt >= MAX_WRITE_RETRY_ATTEMPTS {
            return updateResult;
        }

        attempt += 1;
        log:printError(string `---- Rate limit hit while updating contact ${contactId} in '${targetSheet}'. Retrying in ${backoff}s (attempt ${attempt}/${MAX_WRITE_RETRY_ATTEMPTS})`);
        runtime:sleep(backoff);
        backoff *= 2d;
    }
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
    string endCol = getColumnLetter(fields.length() + 1); // +1 for "Last Synced" column
    sheets:Range rangeData = check sheetsClient->getRange(spreadsheetId, targetSheet, string `A:${endCol}`);
    int totalRows = rangeData.values.length();
    if totalRows <= 1 {
        return;
    }
    // Clear from row 2 downward
    string clearRange = string `A2:${endCol}${totalRows}`;
    check sheetsClient->clearRange(spreadsheetId, targetSheet, clearRange);
    log:printInfo(string `---- Cleared ${totalRows - 1} data rows from '${targetSheet}'`);
}

// Export contacts to Google Sheet using the configured sync mode
function exportContactsToSheet(Contact[] contacts, string lastSyncTimestamp, boolean isFullSync) returns string|error {

    string mode = syncMode.trim().toLowerAscii();
    log:printInfo(string `---- Preparing sheet export (mode: ${mode})`);

    // For replace mode: clear ALL possible target sheets upfront — even if the
    // current contact batch is empty.  Clearing only sheets found in `contacts`
    // would leave stale data when the source has no new/updated records.
    if mode == "replace" {
        string[] allTargetSheets = [
            subscriberSheetName, leadSheetName, marketingqualifiedleadSheetName,
            salesqualifiedleadSheetName, opportunitySheetName, customerSheetName,
            evangelistSheetName, otherSheetName, defaultSheetName
        ];
        map<boolean> clearedSheets = {};
        foreach string targetSheet in allTargetSheets {
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

    // Tracks the next available physical row number per sheet for upsert inserts.
    // Seeded from the actual row count returned by buildEmailRowMap and
    // incremented on each successful append — avoids the stale-count bug
    // that emailRowMap.length() + 2 would cause when blank-email rows exist.
    map<int> nextRowBySheet = {};

    string latestTimestamp = lastSyncTimestamp;
    int processedCount = 0;
    boolean limitReached = false;

    foreach Contact contact in contacts {

        // Apply max row limit only during incremental sync runs.
        if !isFullSync && maxRows > 0 {
            if processedCount >= maxRows {
                log:printInfo("Max row limit reached. Stopping export.");
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
            log:printInfo(string `---- Skipping ${contact.id}: missing email`);
            errorCount += 1;
            continue;
        }

        // email is always first — must map to Column A to match the header row.
        (string|int|decimal)[] rowData = [email];
        foreach string fieldName in fields {
            if fieldName != "email" {
                rowData.push(getContactPropertyValue(props, fieldName));
            }
        }
        rowData.push(getCurrentTimestamp());

        boolean writeSucceeded = false;

        if mode == "append" || mode == "replace" {
            // append and replace both just insert a new row
            check ensureHeaderRow(targetSheet);
            error? result = appendSheetRowWithRetry(targetSheet, rowData, contact.id);
            if result is error {
                log:printError(string `---- Insert failed for contact ${contact.id} in '${targetSheet}': ${result.message()}`);
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
                [map<int>, int] [builtMap, totalRowCount] = check buildEmailRowMap(targetSheet);
                emailRowMap = builtMap;
                emailRowMapBySheet[targetSheet] = emailRowMap;
                nextRowBySheet[targetSheet] = totalRowCount + 1;
            }

            int? existingRow = emailRowMap[email];
            if existingRow is int {
                error? result = updateSheetRowWithRetry(targetSheet, existingRow, rowData, contact.id);
                if result is error {
                    log:printError(string `---- Update failed for contact ${contact.id} in '${targetSheet}': ${result.message()}`);
                    errorCount += 1;
                } else {
                    updateCount += 1;
                    writeSucceeded = true;
                }
            } else {
                error? result = appendSheetRowWithRetry(targetSheet, rowData, contact.id);
                if result is error {
                    log:printError(string `---- Insert failed for contact ${contact.id} in '${targetSheet}': ${result.message()}`);
                    errorCount += 1;
                } else {
                    insertCount += 1;
                    writeSucceeded = true;
                    // Assign the actual row number for this new entry, then
                    // advance the counter for the next insert into this sheet.
                    // nextRowBySheet is guaranteed to be seeded when buildEmailRowMap
                    // is first called for this sheet (in the else branch above).
                    // The <int> cast makes this invariant explicit — a panic here
                    // would indicate a real logic bug, not a normal nil case.
                    int nextRow = <int>nextRowBySheet[targetSheet];
                    emailRowMap[email] = nextRow;
                    nextRowBySheet[targetSheet] = nextRow + 1;
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
    log:printInfo(
        string `---- Export summary: inserted ${insertCount}, updated ${updateCount}, failed ${errorCount}${limitInfo}`
    );

    return latestTimestamp;
}
