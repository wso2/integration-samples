import ballerina/log;
import ballerinax/twitter;

public function main() returns error? {
    do {
        twitter:TweetCreateResponse twitterTweetcreateresponse = check twitterClient->/tweets.post({text: "Hello from WSO2 Integrator Twitter Connector! #integration #ballerina"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
