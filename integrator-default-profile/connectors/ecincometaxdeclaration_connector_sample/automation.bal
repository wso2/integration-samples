import ballerina/log;
import ballerinax/sap.successfactors.ecincometaxdeclaration;

public function main() returns error? {
    do {
        ecincometaxdeclaration:Wrapper ecincometaxdeclarationWrapper = check ecincometaxdeclarationClient->listDeclarationTypes();
        log:printInfo(ecincometaxdeclarationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
