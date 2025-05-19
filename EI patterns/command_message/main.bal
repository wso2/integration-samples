import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1 on httpListener {
    isolated resource function post createUserGroup(UserGroupCreateRequest userGroup)
    returns UserGroupCreationResponse|error {
        UserGroupCreationResponse userGroupCreateRequest = check slackClient->/api/usergroups\.create.post(userGroup, mediaType = "x-www-form-urlencoded");
        return userGroupCreateRequest;
    }
}
