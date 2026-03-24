import ballerina/log;
import ballerinax/salesforce;

listener salesforce:Listener salesforceListener = new (listenerConfig = {
    auth: {
        refreshUrl: salesforceConfig.refreshUrl,
        refreshToken: salesforceConfig.refreshToken,
        clientId: salesforceConfig.clientId,
        clientSecret: salesforceConfig.clientSecret
    },
    baseUrl: salesforceConfig.baseUrl
});
service "/data/OpportunityChangeEvent" on salesforceListener {

    // Handle creation of new opportunities
    remote function onCreate(salesforce:EventData payload) returns error|() {
    }

    // Handle updates to existing opportunities
    remote function onUpdate(salesforce:EventData payload) returns error|() {
        do {
            // Check if StageName was changed in this update
            string changedStageName = extractStageName(payload);

            // Only proceed if StageName was changed to "Closed Won"
            if changedStageName != "Closed Won" {
                return;
            }

            string opportunityId = extractOpportunityId(payload);

            // Guard: skip if recordId metadata missing
            if opportunityId == "" {
                log:printInfo("Event missing recordId; skipping processing");
                return;
            }

            OpportunityDetails opportunityDetails = check queryOpportunity(opportunityId);

            if !meetsMinimumAmount(opportunityDetails.amount, minDealAmount) {
                return;
            }

            // Apply configured filters
            if !passesFilters(opportunityDetails) {
                return;
            }

            string slackMessage = buildSlackMessage(opportunityDetails);
            string targetChannel = getChannelForDealSize(opportunityDetails.amount);

            error? sendResult = sendSlackMessage(messageText = slackMessage, channelName = targetChannel);

            if sendResult is error {
                log:printError("Failed to send notification", opportunityId = opportunityId, 'error = sendResult);
                return sendResult;
            }

            log:printInfo("Notification sent successfully", opportunityId = opportunityId);

        } on fail error err {
            log:printError("Error processing opportunity", 'error = err);
            return error("unhandled error", err);
        }
    }

    // Handle deletion of opportunities
    remote function onDelete(salesforce:EventData payload) returns error|() {
    }

    // Handle restoration of deleted opportunities
    remote function onRestore(salesforce:EventData payload) returns error|() {
    }
}
