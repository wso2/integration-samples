import ballerina/log;
import ballerinax/xero.accounts;

public function main() returns error? {
    do {
        accounts:Accounts chartOfAccounts = check accountsClient->getAccounts({xeroTenantId: accountsTenantId});
        log:printInfo(chartOfAccounts.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
