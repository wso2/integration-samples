import ballerina/graphql;

listener graphql:Listener graphqlListener = new (listenTo = 8080);

service /api/v1 on graphqlListener {

    resource function get project(string organizationID, string projectID) returns Project|error {
        Project result = check zoho->/books/v3/projects/[projectID].get(organization_id = organizationID);
        return result;
    }

    remote function createProject() returns Project|error {
        Project result = check zoho->/books/v3/projects.post(projectRequest, organization_id = organizationID);
        return result;
    }
}

