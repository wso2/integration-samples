import ballerina/log;
import ballerinax/sap.businessone.sales;

public function main() returns error? {
    do {
        sales:BlanketAgreementsCollectionResponse blanketAgreements = check salesClient->listBlanketAgreements();
        log:printInfo("Retrieved SAP Business One blanket agreements", agreements = blanketAgreements);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

