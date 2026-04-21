import ballerina/log;
import ballerinax/hubspot.crm.obj.lineitems;

public function main() returns error? {
    do {
        lineitems:SimplePublicObject result = check lineitemsClient->/.post({associations: [], properties: {"hs_product_id": "1234", "quantity": "2", "price": "19.99", "name": "Sample Line Item"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
