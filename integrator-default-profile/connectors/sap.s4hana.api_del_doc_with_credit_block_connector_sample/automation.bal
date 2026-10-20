import ballerina/log;
import ballerinax/sap.s4hana.api_del_doc_with_credit_block;

public function main() returns error? {
    do {
        api_del_doc_with_credit_block:CollectionOfA_CreditBlockedDeliveryDocWrapper result = check apiDelDocWithCreditBlockClient->listA_CreditBlockedDeliveryDocs(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
