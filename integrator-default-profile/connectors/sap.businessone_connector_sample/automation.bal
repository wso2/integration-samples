import ballerina/log;

public function main() returns error? {
    do {
        json result = check businessoneClient->post("BusinessPartners", {CardCode: "C0001", CardName: "Example Customer Ltd", CardType: "cCustomer"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

