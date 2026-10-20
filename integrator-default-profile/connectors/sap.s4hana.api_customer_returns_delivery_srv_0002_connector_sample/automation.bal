import ballerina/log;
import ballerinax/sap.s4hana.api_customer_returns_delivery_srv_0002;

public function main() returns error? {
    do {
        api_customer_returns_delivery_srv_0002:CollectionOfA_ReturnsDeliveryHeaderWrapper result = check apiCustomerReturnsDeliverySrv0002Client->listA_ReturnsDeliveryHeaders(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
