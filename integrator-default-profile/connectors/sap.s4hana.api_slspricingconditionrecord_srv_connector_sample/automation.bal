import ballerina/log;
import ballerinax/sap.s4hana.api_slspricingconditionrecord_srv.oas;

public function main() returns error? {
    do {
        oas:A_SlsPrcgConditionRecordWrapper createdConditionRecord = check apiSlspricingconditionrecordSrvClient->createA_SlsPrcgConditionRecord({ConditionRecord: "0000000123", ConditionSequentialNumber: "1", ConditionTable: "304", ConditionApplication: "V", ConditionType: "PPR0"});
        log:printInfo(createdConditionRecord.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
