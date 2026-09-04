import ballerina/log;
import ballerinax/aws.redshiftdata;

public function main() returns error? {
    do {
        redshiftdata:ExecutionResponse executionResponse = check redshiftdataClient->execute(`SELECT id, name FROM users LIMIT 10`);
        log:printInfo(string `Statement submitted with ID: ${executionResponse.statementId}`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
