import ballerina/log;
import ballerinax/sap.businessone.inventory;

public function main() returns error? {
    do {
        inventory:ItemsCollectionResponse inventoryItems = check inventoryClient->listItems();
        log:printInfo("Inventory items retrieved", response = inventoryItems);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

