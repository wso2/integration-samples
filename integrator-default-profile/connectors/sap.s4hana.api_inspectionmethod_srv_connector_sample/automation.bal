import ballerina/log;
import ballerinax/sap.s4hana.api_inspectionmethod_srv;

public function main() returns error? {
    do {
        api_inspectionmethod_srv:CollectionOfA_InspectionMethodWrapper result = check apiInspectionmethodSrvClient->listA_InspectionMethods(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
