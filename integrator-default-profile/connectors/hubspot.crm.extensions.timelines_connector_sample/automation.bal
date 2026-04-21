import ballerina/log;
import ballerinax/hubspot.crm.extensions.timelines;

public function main() returns error? {
    do {
        timelines:TimelineEventTemplate result = check timelinesClient->/[12345]/event\-templates.post({name: "Connector Sample Event Type", tokens: [], objectType: "contacts"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
