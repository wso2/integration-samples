import ballerina/log;
import ballerinax/hubspot.crm.engagements.calls;

public function main() returns error? {
    do {
        calls:SimplePublicObject result = check callsClient->/.post({associations: [], properties: {"hs_timestamp": "2025-01-15T10:30:00.000Z", "hs_call_title": "Discovery Call", "hs_call_body": "Initial discovery call with prospect", "hs_call_duration": "300000", "hs_call_status": "COMPLETED"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
