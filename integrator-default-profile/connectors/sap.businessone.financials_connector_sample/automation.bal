import ballerina/log;
import ballerinax/sap.businessone.financials;

public function main() returns error? {
    do {
        financials:JournalEntriesCollectionResponse result = check financialsClient->listJournalEntries();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

