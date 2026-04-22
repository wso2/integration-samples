import ballerina/log;
import ballerinax/hubspot.crm.obj.deals;

public function main() returns error? {
    do {
        deals:SimplePublicObject result = check dealsClient->/.post({associations: [], objectWriteTraceId: "deal-trace-001", properties: {"dealname": "Sample Deal", "amount": "1000", "dealstage": "appointmentscheduled", "pipeline": "default", "closedate": "2026-12-31"}});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
