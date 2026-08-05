import ballerina/log;
import ballerinax/pricefx;

public function main() returns error? {
    do {
        pricefx:ListPriceListTypesEnvelope priceListTypes = check pricefxClient->listPriceListTypes();
        log:printInfo(priceListTypes.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
