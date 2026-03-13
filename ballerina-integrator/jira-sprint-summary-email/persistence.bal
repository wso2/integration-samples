import ballerina/io;
import ballerina/file;
import ballerina/log;

const string PROCESSED_SPRINTS_FILE = "processed_sprints.json";

// Load processed sprint IDs from persistent storage
function loadProcessedSprints() returns map<boolean> {
    map<boolean> processedSprints = {};
    
    boolean|error fileExists = file:test(PROCESSED_SPRINTS_FILE, file:EXISTS);
    if fileExists is error || !fileExists {
        log:printInfo("No existing processed sprints file found, starting fresh");
        return processedSprints;
    }
    
    json|error fileContent = io:fileReadJson(PROCESSED_SPRINTS_FILE);
    if fileContent is error {
        log:printWarn(string `Failed to read processed sprints file: ${fileContent.message()}`);
        return processedSprints;
    }
    
    if fileContent is map<json> {
        foreach string sprintId in fileContent.keys() {
            json value = fileContent[sprintId];
            if value is boolean && value {
                processedSprints[sprintId] = true;
            }
        }
        log:printInfo(string `Loaded ${processedSprints.length()} previously processed sprint(s)`);
    }
    
    return processedSprints;
}

// Save processed sprint IDs to persistent storage
function saveProcessedSprints(map<boolean> processedSprints) {
    json sprintsJson = processedSprints.toJson();
    
    error? writeResult = io:fileWriteJson(PROCESSED_SPRINTS_FILE, sprintsJson);
    if writeResult is error {
        log:printError(string `Failed to save processed sprints: ${writeResult.message()}`);
    } else {
        log:printDebug(string `Saved ${processedSprints.length()} processed sprint(s) to disk`);
    }
}
