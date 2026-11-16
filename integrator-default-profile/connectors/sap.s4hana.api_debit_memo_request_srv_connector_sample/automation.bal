import ballerina/log;
import ballerinax/sap.s4hana.api_debit_memo_request_srv;

public function main() returns error? {
    do {
        api_debit_memo_request_srv:CollectionOfA_DebitMemoRequestWrapper result = check apiDebitMemoRequestSrvClient->listA_DebitMemoRequests(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
