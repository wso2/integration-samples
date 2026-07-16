import ballerina/log;
import ballerinax/sap.businessone.crm;

public function main() returns error? {
    do {
        crm:SalesOpportunitiesCollectionResponse crmSalesopportunitiescollectionresponse = check crmClient->listSalesOpportunities();
        log:printInfo(crmSalesopportunitiescollectionresponse.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

