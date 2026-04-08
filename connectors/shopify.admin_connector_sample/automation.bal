import ballerina/log;
import ballerinax/shopify.admin;

public function main() returns error? {
    do {
        admin:ProductList adminProductlist = check adminClient->getProducts();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
