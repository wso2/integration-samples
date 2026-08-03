import ballerina/log;
import ballerinax/pricefx.oas;

public function main() returns error? {
    do {
        oas:ListPriceListTypesEnvelope priceListTypes = check pricefxClient->listPriceListTypes();
        log:printInfo(priceListTypes.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
