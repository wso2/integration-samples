import ballerina/log;
import ballerinax/scim;

public function main() returns error? {
    do {
        scim:UserResponseObject scimUserresponseobject = check scimClient->/Users.post(<scim:UserObject>{userName: "john.doe@example.com", password: "P@ssword123"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
