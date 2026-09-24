import ballerina/log;
import ballerinax/sap.successfactors.ecadvances;

public function main() returns error? {
    do {
        ecadvances:Wrapper ecadvancesWrapper = check ecadvancesClient->listAdvancesInstallmentss();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    log:printInfo("Advances installments retrieved");
}
