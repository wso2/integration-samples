import ballerina/log;
import ballerinax/sap.successfactors.ecdismissalprotection;

public function main() returns error? {
    do {
        ecdismissalprotection:Wrapper ecdismissalprotectionWrapper = check ecdismissalprotectionClient->listEmployeeDismissalProtectionDetails();
        log:printInfo(ecdismissalprotectionWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
