import ballerina/log;
import ballerinax/hubspot.crm.engagements.communications;

public function main() returns error? {
    do {
        communications:SimplePublicObject result = check communicationsClient->/.post({associations: [], properties: {"hs_communication_channel_type": "EMAIL", "hs_communication_logged_from": "CRM", "hs_communication_body": "Hello from WSO2 Integrator"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
