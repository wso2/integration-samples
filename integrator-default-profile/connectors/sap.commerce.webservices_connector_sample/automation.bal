import ballerina/log;
import ballerinax/sap.commerce.webservices;

public function main() returns error? {
    do {
        webservices:BaseSiteList|xml webservicesBasesitelistXml = check webservicesClient->getBaseSites();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
