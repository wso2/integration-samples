import ballerina/log;
import ballerinax/sap.businessone.localization;

public function main() returns error? {
    do {
        localization:BEMReplicationPeriodsCollectionResponse localizationBemreplicationperiodscollectionresponse = check localizationClient->listBEMReplicationPeriods();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

