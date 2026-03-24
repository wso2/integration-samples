import ballerina/lang.regexp;
import ballerina/log;
import ballerinax/salesforce;

// Extracts stage name from Salesforce event payload
function extractStageName(salesforce:EventData payload) returns string {
    json stageValue = payload.changedData[FIELD_STAGE_NAME];
    return stageValue is string ? stageValue : "";
}

// Extracts opportunity ID from event metadata
function extractOpportunityId(salesforce:EventData payload) returns string {
    return payload.metadata?.recordId ?: "";
}

// Validates Salesforce record ID format
function isValidSalesforceId(string recordId) returns boolean {
    int idLength = recordId.length();
    if idLength != 15 && idLength != 18 {
        return false;
    }

    regexp:RegExp nonAlphaNumeric = re `[^a-zA-Z0-9]`;
    string[] parts = nonAlphaNumeric.split(recordId);
    return parts.length() == 1 && parts[0] == recordId;
}

// Executes Salesforce query
function queryOpportunity(string opportunityId) returns OpportunityDetails|error {
    if !isValidSalesforceId(opportunityId) {
        return error("Invalid Salesforce opportunity Id format");
    }

    string soqlQuery = string `SELECT ${FIELD_ID}, ${FIELD_NAME}, ${FIELD_AMOUNT}, ${FIELD_STAGE_NAME}, ${FIELD_CLOSE_DATE}, ${FIELD_TYPE}, ${FIELD_LEAD_SOURCE}, ${FIELD_OWNER}.${FIELD_NAME}, ${FIELD_ACCOUNT}.${FIELD_NAME}, ${FIELD_MAIN_COMPETITORS}, ${FIELD_DESCRIPTION} FROM Opportunity WHERE ${FIELD_ID} = '${opportunityId}'`;

    stream<record {|anydata...;|}, error?> resultStream = check salesforceClient->query(soqlQuery);

    record {|anydata...;|}[] records = check from record {} recordItem in resultStream
        select recordItem;

    if records.length() == 0 {
        return error("No opportunity found for Id: " + opportunityId);
    }

    return parseOpportunityRecord(records[0]);
}

// Parses raw Salesforce record into structured opportunity details
function parseOpportunityRecord(record {} opportunityRecord) returns OpportunityDetails {
    anydata rawAmount = opportunityRecord[FIELD_AMOUNT];
    anydata rawName = opportunityRecord[FIELD_NAME];
    anydata rawStageName = opportunityRecord[FIELD_STAGE_NAME];
    anydata rawCloseDate = opportunityRecord[FIELD_CLOSE_DATE];
    anydata rawType = opportunityRecord[FIELD_TYPE];
    anydata rawLeadSource = opportunityRecord[FIELD_LEAD_SOURCE];
    anydata rawCompetitor = opportunityRecord[FIELD_MAIN_COMPETITORS];
    anydata rawDescription = opportunityRecord[FIELD_DESCRIPTION];
    anydata ownerObject = opportunityRecord[FIELD_OWNER];
    anydata accountObject = opportunityRecord[FIELD_ACCOUNT];

    decimal amount = rawAmount is decimal ? rawAmount : (rawAmount is int ? <decimal>rawAmount : 0.0);
    string name = rawName is string ? rawName : "";
    string stageName = rawStageName is string ? rawStageName : "";
    string closeDate = rawCloseDate is string ? rawCloseDate : "";
    string opportunityType = rawType is string ? rawType : "";
    string leadSource = rawLeadSource is string ? rawLeadSource : "";
    string competitorInfo = rawCompetitor is string ? rawCompetitor : "";
    string description = rawDescription is string ? rawDescription : "";

    string owner = "";
    if ownerObject is map<anydata> {
        anydata ownerName = ownerObject[FIELD_NAME];
        owner = ownerName is string ? ownerName : "";
    }

    string account = "";
    if accountObject is map<anydata> {
        anydata accountName = accountObject[FIELD_NAME];
        account = accountName is string ? accountName : "";
    }

    return {
        name: name,
        amount: amount,
        owner: owner,
        account: account,
        wonReason: "",
        stageName: stageName,
        closeDate: closeDate,
        opportunityType: opportunityType,
        leadSource: leadSource,
        competitorInfo: competitorInfo,
        description: description
    };
}

// Checks if opportunity amount meets minimum threshold
function meetsMinimumAmount(decimal amount, decimal minimumAmount) returns boolean {
    return amount >= minimumAmount;
}

// Checks if opportunity passes all configured filters
function passesFilters(OpportunityDetails details) returns boolean {
    // Filter by record type
    if allowedTypes.length() > 0 && !allowedTypes.some(t => t == details.opportunityType) {
        return false;
    }

    // Filter by owner
    if allowedOwners.length() > 0 && !allowedOwners.some(o => o == details.owner) {
        return false;
    }

    return true;
}

// Builds formatted Slack message from opportunity details
function buildSlackMessage(OpportunityDetails details) returns string {
    string ownerDisplay = formatOwnerMention(details.owner);

    string message = string `*Opportunity Closed Won*
*Deal:* ${details.name}
*Amount:* ${details.amount.toString()}
*Close Date:* ${details.closeDate}
*Owner:* ${ownerDisplay}
*Account:* ${details.account}`;

    // Add optional fields
    message += addOptionalField("Type", details.opportunityType);
    message += addOptionalField("Lead Source", details.leadSource);
    message += addOptionalField("Competitor", details.competitorInfo);
    message += addOptionalField("Description", details.description);
    message += addOptionalField("Won Reason", details.wonReason);

    return message;
}

// Formats owner name with Slack mention if mapping exists
function formatOwnerMention(string ownerName) returns string {
    string slackHandle = getSlackHandleForOwner(ownerName);
    if slackHandle == "" {
        return ownerName;
    }
    // Mapping contains a Slack user ID (optionally prefixed with @)
    string userId = slackHandle.startsWith("@") ? slackHandle.substring(1) : slackHandle;
    return "<@" + userId + ">";
}

// Adds optional field to message if value exists
function addOptionalField(string label, string value) returns string {
    return value != "" ? string `
*${label}:* ${value}` : "";
}

// Maps Salesforce owner name to Slack handle
function getSlackHandleForOwner(string ownerName) returns string {
    regexp:RegExp separator = re `:`;
    foreach string mapping in ownerSlackMapping {
        string[] parts = separator.split(mapping);
        if parts.length() == 2 && parts[0].trim() == ownerName {
            return parts[1].trim();
        }
    }
    return "";
}

// Determines the appropriate Slack channel based on deal size
function getChannelForDealSize(decimal amount) returns string {
    string selectedChannel = slackConfig.slackChannel;
    decimal highestThreshold = 0.0;
    regexp:RegExp separator = re `:`;

    foreach string tierConfig in dealSizeTierChannels {
        string[] parts = separator.split(tierConfig);
        if parts.length() == 2 {
            decimal|error threshold = decimal:fromString(parts[0].trim());
            if threshold is decimal && amount >= threshold && threshold > highestThreshold {
                highestThreshold = threshold;
                selectedChannel = parts[1].trim();
            }
        }
    }

    return selectedChannel;
}

// Sends Slack message using Slack client
function sendSlackMessage(string messageText, string channelName) returns error? {
    return sendViaSlackClient(messageText, channelName);
}

// Sends message using Slack API client
function sendViaSlackClient(string messageText, string channelName) returns error? {
    var response = slackClient->/chat\.postMessage.post({
        channel: channelName,
        text: messageText
    });

    if response is error {
        // Check if this is a data binding error related to bot_id or MessageObjBotId
        string errorMsg = response.message();
        if errorMsg.includes("Payload binding failed") && 
           (errorMsg.includes("bot_id") || errorMsg.includes("MessageObjBotId")) {
            // Message was sent successfully, just ignore the binding error
            log:printInfo("Slack message sent successfully (ignoring response binding issue)");
            return;
        }
        return response;
    }
    
    return;
}
