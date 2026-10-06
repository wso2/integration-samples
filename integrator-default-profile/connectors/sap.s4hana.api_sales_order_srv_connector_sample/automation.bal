import ballerina/log;
import ballerinax/sap.s4hana.api_sales_order_srv;

public function main() returns error? {
    do {
        api_sales_order_srv:CollectionOfA_SalesOrderWrapper result = check apiSalesOrderSrvClient->listA_SalesOrders(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
