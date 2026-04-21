import ballerina/log;
import ballerinax/sap.s4hana.api_sd_sa_soldtopartydetn;

public function main() returns error? {
    do {
        api_sd_sa_soldtopartydetn:CollectionOfA_DelivSchedSoldToPartyDetnWrapper result = check apiSdSaSoldtopartydetnClient->listA_DelivSchedSoldToPartyDetns();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    
}
