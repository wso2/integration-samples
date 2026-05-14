import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /hello on httpDefaultListener {
    resource function get greeting() returns json|error {
        do {
            json response = check externalApi->get("/");
            return response;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
