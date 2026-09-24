import ballerina/log;
import ballerinax/sap.successfactors.ectimeoff;

public function main() returns error? {
    do {
        ectimeoff:Wrapper ectimeoffWrapper = check ectimeoffClient->listTimeAccountPostingRules();
        log:printInfo(ectimeoffWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
