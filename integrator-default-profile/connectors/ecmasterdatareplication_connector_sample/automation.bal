import ballerina/log;
import ballerinax/sap.successfactors.ecmasterdatareplication;

public function main() returns error? {
    do {
        ecmasterdatareplication:Wrapper ecmasterdatareplicationWrapper = check ecmasterdatareplicationClient->listEmployeeDataReplicationConfirmationErrorMessages();
        log:printInfo(ecmasterdatareplicationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
