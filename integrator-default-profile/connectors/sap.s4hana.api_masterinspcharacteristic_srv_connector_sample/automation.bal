import ballerina/log;
import ballerinax/sap.s4hana.api_masterinspcharacteristic_srv;

public function main() returns error? {
    do {
        api_masterinspcharacteristic_srv:CollectionOfA_InspectionSpecificationWrapper result = check apiMasterinspcharacteristicSrvClient->listA_InspectionSpecifications(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
