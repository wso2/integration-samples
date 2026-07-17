import ballerina/log;
import ballerinax/sap.businessone.businesspartners;

public function main() returns error? {
    do {
        businesspartners:BusinessPartner result = check businesspartnersClient->createBusinessPartners({CardCode: "C00001", CardName: "Acme Corp", CardType: "cCustomer"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

