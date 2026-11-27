import ballerina/log;
import ballerinax/plaid;

public function main() returns error? {
    do {
        plaid:InstitutionsGetResponse institutions = check plaidClient->institutionsGet({offset: 0, count: 10, countryCodes: ["US"]});
        log:printInfo(institutions.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
