import ballerina/log;
import ballerinax/sap.s4hana.api_billing_document_srv;

public function main() returns error? {
    do {
        api_billing_document_srv:CollectionOfA_BillingDocumentWrapper result = check apiBillingDocumentSrvClient->listA_BillingDocuments(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
