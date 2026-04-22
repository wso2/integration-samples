import ballerina/log;
import ballerinax/sap.s4hana.api_sd_incoterms_srv;

public function main() returns error? {
    do {
        api_sd_incoterms_srv:CollectionOfA_IncotermsClassificationWrapper result = check apiSdIncotermsSrvClient->listA_IncotermsClassifications();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
