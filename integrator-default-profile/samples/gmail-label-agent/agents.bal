import ballerina/ai;
import ballerinax/ai.openai;
import ballerinax/googleapis.gmail;

final openai:ModelProvider emailLabelModel = check new (openAiApiKey, modelType = openai:GPT_6_LUNA, apiType = openai:RESPONSES);

final ai:Agent emailLabelAgent = check new (
    systemPrompt = {
        role: string `Gmail Email Labeler`,
        instructions: string `You organize a Gmail inbox by labeling each new email you are given (message id, sender, subject and snippet).
For every email, follow these steps in order:
1. Call listLabels to read the existing labels.
2. Pick the existing user label that best matches the email and call applyLabel with the message id and that label's id. Never apply system labels such as INBOX, UNREAD or CATEGORY_*.
3. If no existing label fits, call createLabel with a short, descriptive name that starts with 'AI/' (for example 'AI/Invoices'), then call applyLabel with the new label's id. Prefer reusing an existing 'AI/' label over creating a near-duplicate.
4. If the email is promotional (marketing, newsletters, discounts, sales offers, advertisements), call removeFromInbox with the message id so it leaves the inbox. Do not remove personal, transactional, security or work emails from the inbox.
Finish with one short sentence stating which label was applied and whether the email was removed from the inbox.`
    },
    model = emailLabelModel,
    tools = [listLabels, applyLabel, createLabel, removeFromInbox],
    memory = ()
);

# Lists the labels that exist in the mailbox.
# + return - the labels, each with its id, name and type (system or user)
@ai:AgentTool
isolated function listLabels() returns LabelInfo[]|error {
    gmail:ListLabelsResponse response = check gmailClient->/users/me/labels;
    gmail:Label[] labels = response.labels ?: [];
    LabelInfo[] result = [];
    foreach gmail:Label item in labels {
        string? labelId = item.id;
        string? labelName = item.name;
        if labelId is string && labelName is string {
            result.push({id: labelId, name: labelName, 'type: item.'type ?: "user"});
        }
    }
    return result;
}

# Applies an existing label to an email.
# + messageId - the id of the email message
# + labelId - the id of the label to apply
# + return - a confirmation message
@ai:AgentTool
isolated function applyLabel(string messageId, string labelId) returns string|error {
    gmail:Message _ = check gmailClient->/users/me/messages/[messageId]/modify.post({addLabelIds: [labelId]});
    return string `Applied label ${labelId} to message ${messageId}`;
}

# Creates a new label. The name must start with the prefix AI/ (for example AI/Invoices).
# + name - the label name, which must start with the prefix AI/
# + return - the id of the created label
@ai:AgentTool
isolated function createLabel(string name) returns string|error {
    if !name.startsWith("AI/") {
        return error("New label names must start with \"AI/\"");
    }
    gmail:Label created = check gmailClient->/users/me/labels.post({name: name});
    string? createdId = created.id;
    if createdId is () {
        return error("Gmail did not return an id for the new label");
    }
    return createdId;
}

# Removes an email from the inbox (archives it) without deleting it. Use only for promotional emails.
# + messageId - the id of the email message
# + return - a confirmation message
@ai:AgentTool
isolated function removeFromInbox(string messageId) returns string|error {
    gmail:Message _ = check gmailClient->/users/me/messages/[messageId]/modify.post({removeLabelIds: ["INBOX"]});
    return string `Removed message ${messageId} from the inbox`;
}
