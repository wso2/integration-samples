import ballerina/log;
import ballerinax/mailchimp.marketing;

public function main() returns error? {
    do {
        marketing:ListMembers2 marketingListmembers2 = check marketingClient->/lists/[mailchimpListId]/members.post({emailAddress: mailchimpMemberEmail, status: mailchimpMemberStatus});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
