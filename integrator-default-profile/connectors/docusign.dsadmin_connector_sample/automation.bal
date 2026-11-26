import ballerina/log;
import ballerinax/docusign.dsadmin;

public function main() returns error? {
    do {
        dsadmin:OrganizationsResponse organizations = check dsadminClient->/v2/organizations.get();
        log:printInfo(organizations.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
