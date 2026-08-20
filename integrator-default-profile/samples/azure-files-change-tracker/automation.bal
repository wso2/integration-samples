import ballerina/log;

import ballerinax/azure.storage.files;

// The snapshot the previous run saved on the share; excluded from the diff below.
const SNAPSHOT_PATH = "/.change-tracker-snapshot.json";

public function main() returns error? {
    do {
        // The previous run's view of the share: file path -> entity tag.
        map<string> previous = {};
        boolean snapshotExists = check shareClient->hasFile(SNAPSHOT_PATH);
        if snapshotExists {
            json stored = check shareClient->getFile(SNAPSHOT_PATH);
            previous = check stored.cloneWithType();
        }

        // The share's current files, each with its entity tag (a new tag on every write).
        map<string> current = {};
        stream<files:Entry, files:Error?> entries = check shareClient->list("/",
                {recursive: true, includeExtendedInfo: true});
        check entries.forEach(function(files:Entry entry) {
            if !entry.isDirectory && entry.path != SNAPSHOT_PATH {
                current[entry.path] = entry.eTag ?: "";
            }
        });

        // Report every difference since the previous run.
        foreach [string, string] [path, eTag] in current.entries() {
            string? known = previous[path];
            if known is () {
                onFileCreated(path);
            } else if known != eTag {
                onFileModified(path);
            }
        }
        foreach string path in previous.keys() {
            if !current.hasKey(path) {
                onFileDeleted(path);
            }
        }

        // Save the current view on the share for the next run.
        check shareClient->upload(current, SNAPSHOT_PATH);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
