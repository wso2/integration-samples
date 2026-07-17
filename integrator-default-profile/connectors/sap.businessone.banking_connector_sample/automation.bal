import ballerina/log;
import ballerinax/sap.businessone.banking;

public function main() returns error? {
    do {
        banking:BanksCollectionResponse bankingBankscollectionresponse = check bankingClient->listBanks();
        log:printInfo(bankingBankscollectionresponse.toString());
        log:printInfo("List Banks completed.");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

