import ballerina/log;
import ballerinax/xero.files;

public function main() returns error? {
    do {
        files:Folder inbox = check filesClient->getInbox({xeroTenantId: filesTenantId});
        log:printInfo(inbox.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
