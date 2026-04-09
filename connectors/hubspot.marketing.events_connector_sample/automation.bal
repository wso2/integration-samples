import ballerina/log;
import ballerinax/hubspot.marketing.events;

public function main() returns error? {
    do {
        events:MarketingEventDefaultResponse eventsMarketingeventdefaultresponse = check eventsClient->postEventsCreate({externalAccountId: "HSP12345", eventOrganizer: "WSO2 Inc", externalEventId: "EVT2024001", eventName: "WSO2 Tech Summit 2024"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
