import ballerina/log;
import ballerinax/microsoft.onedrive;

public function main() returns error? {
    do {
        onedrive:DriveCollectionResponse result = check onedriveClient->listDrive();
        log:printInfo(result.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
