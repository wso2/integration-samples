import ballerina/log;
import ballerinax/sap.businessone.'service as businessone;

public function main() returns error? {
    do {
        businessone:ContractTemplatesCollectionResponse serviceContracttemplatescollectionresponse = check serviceClient->listContractTemplates();
        log:printInfo(serviceContracttemplatescollectionresponse.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

