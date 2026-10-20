import ballerina/log;
import ballerinax/sap.s4hana.api_outbound_delivery_srv_0002;

public function main() returns error? {
    do {
        api_outbound_delivery_srv_0002:CollectionOfA_OutbDeliveryHeaderWrapper result = check apiOutboundDeliverySrv0002Client->listA_OutbDeliveryHeaders(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
