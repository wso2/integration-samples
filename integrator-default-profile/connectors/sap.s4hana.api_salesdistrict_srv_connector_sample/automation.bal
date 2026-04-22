import ballerina/log;
import ballerinax/sap.s4hana.api_salesdistrict_srv;

public function main() returns error? {
    do {
        api_salesdistrict_srv:CollectionOfA_SalesDistrictWrapper apiSalesdistrictSrvCollectionofaSalesdistrictwrapper = check apiSalesdistrictSrvClient->listA_SalesDistricts();
        log:printInfo(apiSalesdistrictSrvCollectionofaSalesdistrictwrapper.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
