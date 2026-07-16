import ballerina/log;
import ballerinax/sap.businessone.purchasing;

public function main() returns error? {
    do {
        purchasing:PurchaseOrdersCollectionResponse purchasingPurchaseorderscollectionresponse = check purchasingOrdersClient->listPurchaseOrders();
        log:printInfo(purchasingPurchaseorderscollectionresponse.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

