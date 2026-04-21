import ballerina/log;
import ballerinax/hubspot.crm.engagements.tasks;

public function main() returns error? {
    do {
        tasks:SimplePublicObject result = check tasksClient->/.post({associations: [], properties: {"hs_task_subject": "Sample HubSpot Task", "hs_task_body": "Complete integration setup", "hs_task_priority": "HIGH", "hs_task_type": "TODO", "hs_timestamp": "2026-04-17T00:00:00.000Z"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
