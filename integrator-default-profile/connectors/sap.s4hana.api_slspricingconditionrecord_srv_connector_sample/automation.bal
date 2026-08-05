import ballerina/log;
import ballerinax/sap.s4hana.api_slspricingconditionrecord_srv;

public function main() returns error? {
    do {
        api_slspricingconditionrecord_srv:CollectionOfA_SlsPrcgConditionRecordWrapper conditionRecords = check apiSlspricingconditionrecordSrvClient->listA_SlsPrcgConditionRecords();
        log:printInfo(conditionRecords.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
