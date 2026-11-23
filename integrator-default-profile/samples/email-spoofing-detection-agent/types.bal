
public type EmailHeaderAnalysis record {|
    string spf;
    string dkim;
    string dmarc;
    string initialIP;
    string organization;
    string country;
    string city;
    string recentSpamActivity;
    string ipSenderReputation;
    string messageId;
    string subject;
    string sender;
    string spoofingRisk;
    string[] reasons;
|};

type EmailSecurityReport record {|
    EmailHeaderAnalysis[] emails;
|};

# Facts that the analyzeEmailHeaders function reads from the headers of one email.
public type EmailHeaderFacts record {|
    # Gmail message ID
    string messageId;
    # Subject header
    string subject;
    # From header, including the display name
    string sender;
    # Reply-To header, or "not found"
    string replyTo;
    # Return-Path header, or "not found"
    string returnPath;
    # SPF result: pass, fail, neutral, unknown, or not found
    string spf;
    # DKIM result: pass, fail, error, unknown, found, or not found
    string dkim;
    # DMARC result: pass, fail, unknown, or not found
    string dmarc;
    # Full Authentication-Results header, or "not found"
    string authenticationResults;
    # First public IP address in the earliest Received header, or "Originating IP Not Found"
    string initialIP;
    # Organization that owns the originating IP address
    string organization;
    # Country of the originating IP address
    string country;
    # City of the originating IP address
    string city;
    # Spam activity of the originating IP address, based on its fraud score
    string recentSpamActivity;
    # Reputation of the originating IP address: Good, OK, Suspicious, Poor, Bad, or Unknown
    string ipSenderReputation;
|};

# A header of a Gmail message, as returned by the Gmail API.
#
# + name - Header name
# + value - Header value
type GmailHeader record {
    string name;
    string value;
};

# The headers of a Gmail message, as returned by the Gmail API with format=metadata. Unlike the Gmail connector, it keeps every header, including all the Received headers.
#
# + id - Gmail message ID
# + payload - Message payload that holds the headers in their original order
type GmailMessageHeaders record {
    string id;
    record {
        GmailHeader[] headers = [];
    } payload;
};

# A request to the analyze endpoint. Give either Gmail message IDs or a Gmail search query.
public type AnalyzeRequest record {|
    # Gmail search query that selects the emails to analyze. Defaults to "in:inbox newer_than:1d".
    string query?;
    # IDs of the Gmail messages to analyze
    string[] messageIds?;
|};

// The search query used when a request gives neither message IDs nor a query.
const string DEFAULT_QUERY = "in:inbox newer_than:1d";
