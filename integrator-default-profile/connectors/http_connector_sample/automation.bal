import ballerina/http;
import ballerina/log;

public function main() returns error? {
    do {
        http:Response result = check httpClient->get("/");
        log:printInfo("status code: " + result.statusCode.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
