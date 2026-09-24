import ballerina/log;
import ballerinax/sap.successfactors.ecemploymentinformation;

public function main() returns error? {
    do {
        ecemploymentinformation:Wrapper_1 ecemploymentinformationWrapper1 = check ecemploymentinformationClient->listEmpEmployments();
        log:printInfo(ecemploymentinformationWrapper1.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
