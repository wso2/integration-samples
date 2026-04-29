import ballerina/graphql;
import ballerina/log;

listener graphql:Listener graphqlListener = new (graphqlPort);

service /graphql on graphqlListener {
    resource function get getBookInfo(graphql:Context ctx) returns BookInfo {
        _ = ctx;
        log:printInfo("getBookInfo invoked");
        return new ();
    }
}
