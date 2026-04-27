import ballerina/graphql;
import ballerina/log;

public function main() returns error? {
    do {
        graphql:GenericResponseWithErrors result = check graphqlClient->execute("{ __typename }");
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
