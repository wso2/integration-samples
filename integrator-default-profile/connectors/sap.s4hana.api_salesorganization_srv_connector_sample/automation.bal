import ballerina/log;
import ballerinax/sap.s4hana.api_salesorganization_srv;

public function main() returns error? {
    do {
        api_salesorganization_srv:CollectionOfA_SalesOrganizationWrapper result = check apiSalesorganizationSrvClient->listA_SalesOrganizations(\$top = 5);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
