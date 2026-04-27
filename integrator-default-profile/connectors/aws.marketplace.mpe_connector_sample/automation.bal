import ballerina/log;
import ballerinax/aws.marketplace.mpe;

public function main() returns error? {
    do {
        mpe:EntitlementsResponse mpeEntitlementsresponse = check mpeClient->getEntitlements(productCode = awsProductCode);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
