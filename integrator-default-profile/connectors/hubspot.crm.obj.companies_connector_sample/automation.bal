import ballerina/log;
import ballerinax/hubspot.crm.obj.companies;

public function main() returns error? {
    do {
        companies:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging result = check companiesClient->/companies.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
