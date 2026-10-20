import ballerina/log;
import ballerinax/sap.s4hana.api_inspectionlot_srv;

public function main() returns error? {
    do {
        api_inspectionlot_srv:CollectionOfA_InspectionLotWrapper result = check apiInspectionlotSrvClient->listA_InspectionLots(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
