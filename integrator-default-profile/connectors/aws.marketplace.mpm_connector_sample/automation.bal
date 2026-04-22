import ballerina/log;
import ballerinax/aws.marketplace.mpm;

public function main() returns error? {
    do {
        mpm:BatchMeterUsageResponse mpmBatchmeterusageresponse = check mpmClient->batchMeterUsage(productCode = "\"prod-abc123xyzdefgh\"");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
