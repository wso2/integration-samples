import ballerina/log;
import ballerinax/sap.s4hana.api_customer_return_srv;

public function main() returns error? {
    do {
        api_customer_return_srv:CollectionOfA_CustomerReturnWrapper result = check apiCustomerReturnSrvClient->listA_CustomerReturns(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
