import ballerina/log;
import ballerinax/sap.s4hana.api_sales_inquiry_srv;

public function main() returns error? {
    do {
        api_sales_inquiry_srv:CollectionOfA_SalesInquiryWrapper result = check apiSalesInquirySrvClient->listA_SalesInquiries(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
