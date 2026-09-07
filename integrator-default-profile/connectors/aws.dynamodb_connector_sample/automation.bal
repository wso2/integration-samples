import ballerina/log;
import ballerinax/aws.dynamodb;

public function main() returns error? {
    do {
        dynamodb:ItemGetOutput itemOutput = check dynamodbClient->getItem({TableName: tableName, Key: {"id": {S: itemId}}});
        log:printInfo(string `Retrieved item ${itemId} from table ${tableName}: ${itemOutput.toString()}`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
