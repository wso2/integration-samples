import ballerina/log;
import ballerinax/sap.s4hana.api_credit_memo_request_srv;

public function main() returns error? {
    do {
        api_credit_memo_request_srv:CollectionOfA_CreditMemoRequestWrapper result = check apiCreditMemoRequestSrvClient->listA_CreditMemoRequests(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
