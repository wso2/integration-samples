import ballerina/log;
import ballerinax/docusign.dsadmin;

public function main() returns error? {
    do {
        dsadmin:OrganizationsResponse dsAdminResult = check dsadminClient->/v2/organizations.get();
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
