import ballerina/log;

import ballerinax/azure.storage.files;

public function main() returns error? {
    do {
        // The previous run's view of the share, bound straight into the snapshot record.
        Snapshot previous = {};
        boolean snapshotExists = check shareClient->hasFile(snapshotPath);
        if snapshotExists {
            previous = check shareClient->getFile(snapshotPath);
        }

        // The share's current files, each with its entity tag (a new tag on every write).
        Snapshot current = {};
        stream<files:Entry, files:Error?> entries = check shareClient->list("/",
                {recursive: true, includeExtendedInfo: true});
        check entries.forEach(function(files:Entry entry) {
            if !entry.isDirectory && entry.path != snapshotPath {
                current.entries[entry.path] = entry.eTag ?: "";
            }
        });

        // Report every difference since the previous run.
        foreach [string, string] [path, eTag] in current.entries.entries() {
            string? known = previous.entries[path];
            if known is () {
                onFileCreated(path);
            } else if known != eTag {
                onFileModified(path);
            }
        }
        foreach string path in previous.entries.keys() {
            if !current.entries.hasKey(path) {
                onFileDeleted(path);
            }
        }

        // Save the current view on the share for the next run.
        check shareClient->upload(current, snapshotPath);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
