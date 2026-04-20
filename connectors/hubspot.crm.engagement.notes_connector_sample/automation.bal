import ballerina/log;
import ballerinax/hubspot.crm.engagement.notes;

public function main() returns error? {
    do {
        notes:SimplePublicObject result = check notesClient->/.post({associations: [], properties: {"hs_note_body": "Sample note created via WSO2 Integrator", "hs_timestamp": "2024-01-01T00:00:00.000Z"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
