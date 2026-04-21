import ballerina/log;
import ballerinax/sap.s4hana.ce_salesorder_0001;

public function main() returns error? {
    do {
        ce_salesorder_0001:CollectionOfSalesOrder ceSalesorder0001Collectionofsalesorder = check ceSalesorder0001Client->listSalesOrders();
        log:printInfo(ceSalesorder0001Collectionofsalesorder.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    
}
