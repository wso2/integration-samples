import ballerina/io;
import ballerina/file;
import ballerina/time;

// File to store the last sync timestamp
const string SYNC_STATE_FILE = "last_sync_timestamp.txt";

// Global variable to track current sync timestamp
string currentSyncTimestamp = lastSyncTimestamp;

// Get the last sync timestamp
function getLastSyncTimestamp() returns string {
    // First check if there's a persisted timestamp in file
    boolean|file:Error fileExistsResult = file:test(SYNC_STATE_FILE, file:EXISTS);
    if fileExistsResult is boolean && fileExistsResult {
        string|error fileContent = io:fileReadString(SYNC_STATE_FILE);
        if fileContent is string {
            string timestamp = fileContent.trim();
            if timestamp != "" {
                io:println(string `---- Loaded checkpoint from file: ${timestamp}`);
                return timestamp;
            }
        }
    }
    
    // Fall back to configurable value
    if currentSyncTimestamp != "" {
        io:println(string `---- Using configured checkpoint: ${currentSyncTimestamp}`);
        return currentSyncTimestamp;
    }
    
    io:println("---- No checkpoint found. Starting full sync");
    return "";
}

// Save the last sync timestamp to file
function saveLastSyncTimestamp(string timestamp) returns error? {
    check io:fileWriteString(SYNC_STATE_FILE, timestamp);
    currentSyncTimestamp = timestamp;
    io:println(string `---- Saved checkpoint: ${timestamp}`);
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
    
    // If parsing fails, include the contact to be safe
    return true;
}
