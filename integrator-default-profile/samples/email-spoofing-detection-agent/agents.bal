import ballerina/ai;
import ballerinax/googleapis.gmail;

# Lists the IDs of Gmail messages that match a Gmail search query, for example 'in:inbox newer_than:1d'. Use it to find the emails to analyze.
# + query - Gmail search query that selects the emails to analyze, for example 'in:inbox newer_than:1d'.
# + return - The IDs of up to 10 matching messages, or an error if Gmail cannot be searched
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.2.1.png"}
isolated function listRecentEmails(string query) returns gmail:ListMessagesResponse|error {
    gmail:ListMessagesResponse gmailListmessagesresponse = check gmailClient->/users/["me"]/messages.get(maxResults = 10, q = query);
    return gmailListmessagesresponse;
}

final ai:Agent emailSecurityAgent = check new (
    systemPrompt = {
        role: string `Email Security Analyst`,
        instructions: string `You are an email security analyst. You check emails in a Gmail inbox for spoofing and phishing and give each one a risk verdict that a person can act on.
Choosing the emails:
- If the request contains Gmail message IDs, analyze exactly those messages.
- Otherwise, call listRecentEmails with the Gmail search query from the request, or "in:inbox newer_than:1d" if none is given. Analyze only the messages it returns. If it returns no messages, return {"emails": []}.
For each email, call analyzeEmailHeadersTool with its message ID. It returns facts that code read from the headers: the sender, Reply-To and Return-Path, the SPF, DKIM, and DMARC results, the full Authentication-Results header, the originating IP address with its organization and location, and the reputation of that IP address. These facts are exact. Copy them into your answer unchanged, and never replace them with your own knowledge. You can analyze several emails in parallel.
Then judge each email from the facts. Look for these warning signs:
- SPF, DKIM, or DMARC fails, or is "not found" or "unknown".
- The Authentication-Results header shows a failing DKIM signature for the From domain even though another signature passes, or DMARC fails although SPF passes (the sending domain is not aligned with the From domain).
- The Reply-To or Return-Path domain differs from the From domain, and a known email service provider does not explain it.
- The display name claims a well-known brand or a person, but the address is from an unrelated or free email domain.
- The From domain looks like a known brand but is misspelled or uses lookalike characters.
- The originating IP has a "Poor" or "Bad" reputation, recent spam activity, or an organization that does not fit the claimed sender or its email provider.
Set spoofingRisk to "HIGH" when there is strong evidence of spoofing or phishing, "MEDIUM" when there are warning signs but no clear proof, and "LOW" when authentication passes and nothing looks suspicious. In reasons, list the evidence behind the verdict as short sentences that quote the actual values. An "Unknown" reputation only means the reputation lookup was not available, so it is not evidence by itself.
Return a JSON object of the form {"emails": [...]} with one entry per analyzed email. Each entry has the fields messageId, subject, sender, spf, dkim, dmarc, initialIP, organization, country, city, recentSpamActivity, and ipSenderReputation, all copied from analyzeEmailHeadersTool, plus spoofingRisk and reasons.`
    }, maxIter = 40, model = check ai:getDefaultModelProvider(), tools = [listRecentEmails, analyzeEmailHeadersTool], memory = ()
);

# Reads the headers of a Gmail message and returns the facts needed to judge whether it is spoofed: the sender, Reply-To and Return-Path, the SPF, DKIM, and DMARC results, the full Authentication-Results header, the originating IP address with its organization and location, and the reputation of that IP address.
# + messageId - The ID of the Gmail message to analyze, as returned by listRecentEmails
# + return - The header facts of the message, or an error if the message cannot be read
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function analyzeEmailHeadersTool(string messageId) returns EmailHeaderFacts|error {
    EmailHeaderFacts result = check analyzeEmailHeaders(messageId);
    return result;
}
