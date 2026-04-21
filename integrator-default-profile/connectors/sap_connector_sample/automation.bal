import ballerina/http;
import ballerina/log;
import ballerinax/sap;

public function main() returns error? {
    do {
        json postResult = check sapClient->post("/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner", {"BusinessPartnerCategory": "1", "FirstName": "John", "LastName": "Doe"});
        log:printInfo(postResult.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
