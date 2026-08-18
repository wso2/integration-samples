import ballerina/log;
import ballerina/smb;

public function main() returns error? {
    do {
        smb:FileInfo[] files = check smbClient->list("/reports");
        log:printInfo("Found " + files.length().toString() + " entries under /reports");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
