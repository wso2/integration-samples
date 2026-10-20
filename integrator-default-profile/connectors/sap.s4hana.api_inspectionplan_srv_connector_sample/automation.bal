import ballerina/log;
import ballerinax/sap.s4hana.api_inspectionplan_srv;

public function main() returns error? {
    do {
        api_inspectionplan_srv:CollectionOfA_InspectionPlanWrapper result = check apiInspectionplanSrvClient->listA_InspectionPlans(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
