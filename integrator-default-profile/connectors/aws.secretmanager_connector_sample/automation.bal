import ballerina/log;
import ballerinax/aws.secretmanager;

public function main() returns error? {
    do {
        secretmanager:SecretValue secretValue = check secretmanagerClient->getSecretValue(awsSecretId);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
