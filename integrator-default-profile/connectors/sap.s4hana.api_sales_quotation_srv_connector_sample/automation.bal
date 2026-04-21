import ballerina/log;
import ballerinax/sap.s4hana.api_sales_quotation_srv;

public function main() returns error? {
    do {
        api_sales_quotation_srv:CollectionOfA_SalesQuotationWrapper result = check apiSalesQuotationSrvClient->listA_SalesQuotations(\$top = 5);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
