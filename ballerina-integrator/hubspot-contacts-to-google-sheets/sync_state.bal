import ballerina/io;
import ballerina/file;
import ballerina/time;
import ballerinax/googleapis.sheets;

// File to store the last sync timestamp
const string SYNC_STATE_FILE = "last_sync_timestamp.txt";
const string SYNC_STATE_SHEET = "_sync_state";
const string SYNC_STATE_CELL = "A1";

// Global variable to track current sync timestamp
string currentSyncTimestamp = lastSyncTimestamp;

// Get the last sync timestamp
function getLastSyncTimestamp() returns string {
    // First check if there's a persisted timestamp in spreadsheet state sheet
    string|error sheetCheckpoint = readCheckpointFromSheet();
    if sheetCheckpoint is string {
        string timestamp = sheetCheckpoint.trim();
        if timestamp != "" {
            currentSyncTimestamp = timestamp;
            io:println(string `---- Loaded checkpoint from sheet '${SYNC_STATE_SHEET}': ${timestamp}`);
            return timestamp;
        }
    }

    // Fallback: check if there's a persisted timestamp in file
    boolean|file:Error fileExistsResult = file:test(SYNC_STATE_FILE, file:EXISTS);
    if fileExistsResult is boolean && fileExistsResult {
        string|error fileContent = io:fileReadString(SYNC_STATE_FILE);
        if fileContent is string {
            string timestamp = fileContent.trim();
            if timestamp != "" {
                currentSyncTimestamp = timestamp;
                io:println(string `---- Loaded checkpoint from file: ${timestamp}`);
                return timestamp;
            }
        }
    }
    
    // Fall back to configurable value
    if currentSyncTimestamp != "" {
        io:println(string `---- Using runtime/configured checkpoint: ${currentSyncTimestamp}`);
        return currentSyncTimestamp;
    }
    
    io:println("---- No checkpoint found. Starting full sync");
    return "";
}

// Save the last sync timestamp to file.
// We advance the checkpoint by 1 ms so that the next incremental run
// uses `updatedAt >= checkpoint + 1ms` semantics, preventing contacts that
// share the exact latest timestamp from being silently skipped forever.
function saveLastSyncTimestamp(string timestamp) returns error? {
    time:Utc|error parsedTime = time:utcFromString(timestamp);
    string checkpointToSave = timestamp;
    if parsedTime is time:Utc {
        // Advance by 1 millisecond (0.001 seconds) so the next run's
        // "strictly after" filter does not re-skip same-millisecond contacts.
        time:Utc advanced = time:utcAddSeconds(parsedTime, 0.001d);
        checkpointToSave = time:utcToString(advanced);
    } else {
        io:println(string `---- Warning: could not advance checkpoint timestamp '${timestamp}': ${parsedTime.message()}. Saving as-is.`);
    }

    currentSyncTimestamp = checkpointToSave;

    error? sheetWriteResult = writeCheckpointToSheet(checkpointToSave);
    if sheetWriteResult is () {
        io:println(string `---- Saved checkpoint in sheet '${SYNC_STATE_SHEET}': ${checkpointToSave}`);
        return;
    }

    error? writeResult = io:fileWriteString(SYNC_STATE_FILE, checkpointToSave);
    if writeResult is error {
        io:println(string `---- Warning: could not persist checkpoint to sheet '${SYNC_STATE_SHEET}': ${sheetWriteResult.message()}.`);
        io:println(string `---- Warning: could not persist checkpoint to '${SYNC_STATE_FILE}': ${writeResult.message()}. Using in-memory checkpoint for this process.`);
        io:println(string `---- Saved checkpoint in memory: ${checkpointToSave}`);
        return;
    }

    io:println(string `---- Warning: could not persist checkpoint to sheet '${SYNC_STATE_SHEET}': ${sheetWriteResult.message()}. Falling back to file.`);

    io:println(string `---- Saved checkpoint: ${checkpointToSave}`);
}

function readCheckpointFromSheet() returns string|error {
    sheets:Cell checkpointCell = check sheetsClient->getCell(spreadsheetId, SYNC_STATE_SHEET, SYNC_STATE_CELL);
    return checkpointCell.value.toString();
}

function ensureSyncStateSheetExists() returns error? {
    sheets:Sheet|error existingSheet = sheetsClient->getSheetByName(spreadsheetId, SYNC_STATE_SHEET);
    if existingSheet is sheets:Sheet {
        return;
    }

    sheets:Sheet|error addedSheet = sheetsClient->addSheet(spreadsheetId, SYNC_STATE_SHEET);
    if addedSheet is error {
        sheets:Sheet|error sheetAfterRetry = sheetsClient->getSheetByName(spreadsheetId, SYNC_STATE_SHEET);
        if sheetAfterRetry is sheets:Sheet {
            return;
        }
        return addedSheet;
    }
}

function writeCheckpointToSheet(string checkpointToSave) returns error? {
    check ensureSyncStateSheetExists();
    check sheetsClient->setCell(spreadsheetId, SYNC_STATE_SHEET, SYNC_STATE_CELL, checkpointToSave);
}

// Get current timestamp in ISO 8601 format
function getCurrentTimestamp() returns string {
    time:Utc currentTime = time:utcNow();
    string timestamp = time:utcToString(currentTime);
    return timestamp;
}

// Compare two ISO 8601 timestamps
function isNewerThan(string timestamp1, string timestamp2) returns boolean {
    if timestamp2 == "" {
        return true;
    }
    
    time:Utc|error time1 = time:utcFromString(timestamp1);
    time:Utc|error time2 = time:utcFromString(timestamp2);

    if time1 is time:Utc && time2 is time:Utc {
        decimal diff = time:utcDiffSeconds(time1, time2);
        return diff > 0d;
    }

    // Log the parse failure so it doesn't go unnoticed, then include the
    // contact to be safe (better to re-process than to silently drop it).
    if time1 is error {
        io:println(string `---- Warning: could not parse timestamp '${timestamp1}': ${time1.message()}. Including contact.`);
    }
    if time2 is error {
        io:println(string `---- Warning: could not parse checkpoint '${timestamp2}': ${time2.message()}. Including contact.`);
    }
    return true;
}
