import ballerina/io;

public function main() returns error? {
    io:println("---- HubSpot -> Google Sheets Sync Started");

    do {
        io:println("---- Validating HubSpot and Google Sheets access");
        check validateExternalConnections();
        io:println("---- Configuration validation passed");
    } on fail error startupErr {
        printRunError(startupErr);
        io:println("---- Startup validation failed. Fix configuration and retry");
        return;
    }
    
    do {
        io:println("---- Run Start");
        io:println("---- Fetching contacts from HubSpot");
        
        // Get the last sync timestamp
        string lastSyncTime = getLastSyncTimestamp();
        
        // replace mode always does a full fetch so the sheet is fully rebuilt each run
        boolean isFullSync = lastSyncTime == "" || syncMode.trim().toLowerAscii() == "replace";
        string effectiveSyncTime = isFullSync ? "" : lastSyncTime;
        
        // Step 1: Fetch contacts from HubSpot (with incremental sync)
        Contact[] contacts = check fetchHubSpotContacts(effectiveSyncTime);
        string latestTimestamp = lastSyncTime;
        
        if contacts.length() == 0 && !isFullSync {
            // Incremental run with no changed contacts — nothing to export.
            io:println("---- No new or updated contacts found");
        } else {
            // Step 2: Export contacts to Google Sheet and get latest timestamp.
            // Always called in replace/full-sync mode so sheet-clearing runs
            // even when the source returns zero contacts.
            io:println("---- Exporting contacts to Google Sheets");
            latestTimestamp = check exportContactsToSheet(contacts, effectiveSyncTime, isFullSync);

            if contacts.length() == 0 {
                io:println("---- No contacts found");
                if isFullSync {
                    latestTimestamp = getCurrentTimestamp();
                }
            }
        }

        // Step 3: Save the latest timestamp for next run after processing finishes.
        if latestTimestamp != lastSyncTime {
            io:println("---- Saving sync checkpoint");
            check saveLastSyncTimestamp(latestTimestamp);
        }
        
        io:println("---- Run Completed");
    } on fail error runErr {
        printRunError(runErr);
    }
}

function printRunError(error err) {
    string errorText = err.toString();

    io:println("---- Run Failed");
    io:println(string `---- Error: ${errorText}`);

    if errorText.includes("Unable to parse range") || errorText.includes("Requested entity was not found") {
        io:println("---- Hint: Verify spreadsheetId and sheet names in Config.toml");
    }

    if errorText.includes("PERMISSION_DENIED") || errorText.includes("insufficient") || errorText.includes("forbidden") {
        io:println("---- Hint: Verify Google OAuth credentials and spreadsheet sharing permissions");
    }

    if errorText.includes("UNAUTHENTICATED") || errorText.includes("401") || errorText.includes("invalid_grant") {
        io:println("---- Hint: Refresh HubSpot/Google tokens in Config.toml");
    }
}
