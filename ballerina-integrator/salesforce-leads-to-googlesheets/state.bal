import ballerina/io;
import ballerina/log;

const string STATE_FILE_PATH = "last_sync_state.txt";

function saveLastSyncTimestamp(string timestamp) returns error? {
    do {
        check io:fileWriteString(STATE_FILE_PATH, timestamp);
        log:printInfo(string `Persisted last sync timestamp to state file: "${timestamp}"`);
    } on fail error e {
        log:printWarn(string `Failed to persist last sync timestamp to state file: ${e.message()}. You must manually update lastSyncTimestamp configuration for the next run.`);
        return e;
    }
}

function loadLastSyncTimestamp() returns string|error {
    do {
        string timestamp = check io:fileReadString(STATE_FILE_PATH);
        log:printInfo(string `Loaded last sync timestamp from state file: "${timestamp}"`);
        return timestamp;
    } on fail {
        log:printInfo("No previous sync state found. Using configured lastSyncTimestamp.");
        return "";
    }
}

function getEffectiveLastSyncTimestamp() returns string {
    if enableIncrementalSync {
        string|error stateTimestamp = loadLastSyncTimestamp();
        if stateTimestamp is string && stateTimestamp != "" {
            return stateTimestamp;
        }
    }
    return lastSyncTimestamp;
}
