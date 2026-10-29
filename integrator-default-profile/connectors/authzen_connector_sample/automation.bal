import ballerina/authzen;
import ballerina/log;

public function main() returns error? {
    do {
        authzen:Decision authzenDecision = check authzenClient->evaluate({subject: {'type: "user", id: "CiRmZDA2MTRkMy1jMzlhLTQ3ODEtYjdiZC04Yjk2ZjVhNTEwMGQSBWxvY2Fs"}, action: {name: "can_create_todo"}, 'resource: {'type: "todo", id: "todo-1"}});
        log:printInfo(authzenDecision.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
