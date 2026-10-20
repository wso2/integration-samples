import ballerina/log;
import ballerinax/sap.s4hana.api_inbound_delivery_srv_0002;

public function main() returns error? {
    do {
        api_inbound_delivery_srv_0002:CollectionOfA_InbDeliveryHeaderWrapper result = check apiInboundDeliverySrv0002Client->listA_InbDeliveryHeaders(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
