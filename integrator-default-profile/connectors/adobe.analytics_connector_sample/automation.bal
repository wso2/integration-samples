import ballerina/log;
import ballerinax/adobe.analytics;

public function main() returns error? {
    do {
        analytics:AnalyticsUser currentUser = check analyticsClient->getCurrentUser(string `${analyticsCompanyId}`);
        log:printInfo(currentUser.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
