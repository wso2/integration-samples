import ballerina/log;
import ballerinax/hubspot.crm.obj.tickets;

public function main() returns error? {
    do {
        tickets:SimplePublicObject result = check ticketsClient->/.post({properties: {"subject": "Test HubSpot Ticket", "hs_pipeline": "0", "hs_pipeline_stage": "1", "hs_ticket_priority": "HIGH"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
