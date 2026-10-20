import ballerina/log;
import ballerinax/sap.s4hana.api_inforecord_process_srv;

public function main() returns error? {
    do {
        api_inforecord_process_srv:CollectionOfA_PurchasingInfoRecordWrapper result = check apiInforecordProcessSrvClient->listA_PurchasingInfoRecords(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
