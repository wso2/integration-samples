import ballerina/log;
import ballerinax/redis;

public function main() returns error? {
    do {
        string setResult = check redisClient->set("\"greeting\"", "\"Hello, World!\"");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
