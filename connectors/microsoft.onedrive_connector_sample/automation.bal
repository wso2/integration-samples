import ballerina/log;
import ballerinax/microsoft.onedrive;

public function main() returns error? {
    do {
        onedrive:DriveItem onedriveDriveitem = check onedriveClient->createChildren("b!sampleDriveId123", "01ABC123DEF456GHIJ", {name: "Projects", folder: {}});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
