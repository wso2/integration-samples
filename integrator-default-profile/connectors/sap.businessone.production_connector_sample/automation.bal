import ballerina/log;
import ballerinax/sap.businessone.production;

public function main() returns error? {
    do {
        production:ProductionOrdersCollectionResponse productionOrders = check sapProductionClient->listProductionOrders();
        log:printInfo(productionOrders.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

