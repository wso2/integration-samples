import ballerina/log;
import ballerinax/mailchimp.marketing;

public function main() returns error? {
    do {
        marketing:ListMembers2 marketingListmembers2 = check marketingClient->/lists/[string `abc123listId`]/members.post({emailAddress: "john@example.com", status: "subscribed"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
