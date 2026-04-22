import ballerina/log;
import ballerinax/hubspot.marketing.campaigns;

public function main() returns error? {
    do {
        campaigns:PublicCampaign campaignResult = check campaignsClient->/.post({properties: {"hs_name": "Summer Sale Campaign"}});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
