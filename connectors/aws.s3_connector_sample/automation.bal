import ballerina/log;
import ballerinax/aws.s3;

public function main() returns error? {
    do {
        check s3Client->createBucket("my-wso2-integration-bucket");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
