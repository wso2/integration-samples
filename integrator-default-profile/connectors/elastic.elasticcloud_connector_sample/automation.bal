import ballerina/log;
import ballerinax/elastic.elasticcloud;

public function main() returns error? {
    do {
        elasticcloud:DeploymentsListResponse elasticcloudDeploymentslistresponse = check elasticcloudClient->/deployments.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
