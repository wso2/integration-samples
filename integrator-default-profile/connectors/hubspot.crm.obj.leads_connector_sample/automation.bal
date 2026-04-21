import ballerina/log;
import ballerinax/hubspot.crm.obj.leads;

public function main() returns error? {
    do {
        leads:SimplePublicObject result = check leadsClient->/.post({associations: [], properties: {}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
