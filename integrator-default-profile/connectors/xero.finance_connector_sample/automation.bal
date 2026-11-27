import ballerina/log;
import ballerinax/xero.finance;

public function main() returns error? {
    do {
        finance:BalanceSheetResponse balanceSheet = check financeClient->getFinancialStatementBalanceSheet({xeroTenantId: financeTenantId});
        log:printInfo(balanceSheet.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
