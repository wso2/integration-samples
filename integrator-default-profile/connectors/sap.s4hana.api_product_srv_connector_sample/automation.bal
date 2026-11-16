import ballerina/log;
import ballerinax/sap.s4hana.api_product_srv;

public function main() returns error? {
    do {
        api_product_srv:CollectionOfA_ProductWrapper result = check apiProductSrvClient->listA_Products(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
