import ballerina/log;
import ballerinax/sap.s4hana.api_qualityinforecord_srv;

public function main() returns error? {
    do {
        api_qualityinforecord_srv:CollectionOfQualityInProcurementWrapper result = check apiQualityinforecordSrvClient->listQualityInProcurements(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
