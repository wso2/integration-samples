import ballerina/log;
import ballerinax/xero.bankfeeds;

public function main() returns error? {
    do {
        bankfeeds:FeedConnections feedConnections = check bankfeedsClient->getFeedConnections({xeroTenantId: bankfeedsTenantId});
        log:printInfo(feedConnections.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
