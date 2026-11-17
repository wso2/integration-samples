import ballerina/lang.regexp;

const string IP_NOT_FOUND = "Originating IP Not Found";
const string NOT_FOUND = "not found";

# Reads the headers of a Gmail message and returns the facts needed to judge whether it is spoofed: the sender,
# Reply-To and Return-Path, the SPF, DKIM, and DMARC results, the full Authentication-Results header, the originating
# IP address with its organization and location, and the reputation of that IP address.
#
# + messageId - The ID of the Gmail message to analyze, as returned by listRecentEmails
# + return - The header facts of the message, or an error if the message cannot be read
isolated function analyzeEmailHeaders(string messageId) returns EmailHeaderFacts|error {
    GmailMessageHeaders message = check gmailApiClient->/users/me/messages/[messageId](format = "metadata");

    // Header names are case-insensitive. Keep the first value of each header, which is the one added by Gmail
    // itself, and keep every Received header, from the newest hop (top) to the oldest hop (bottom).
    map<string> headers = {};
    string[] receivedHeaders = [];
    foreach GmailHeader header in message.payload.headers {
        string name = header.name.toLowerAscii();
        if name == "received" {
            receivedHeaders.push(header.value);
        } else if name == "received-spf" {
            headers[name] = header.value; // Keep the last Received-SPF header, which records the earliest hop
        } else if !headers.hasKey(name) {
            headers[name] = header.value;
        }
    }

    string authenticationResults = headers["authentication-results"] ?: NOT_FOUND;
    string spf = NOT_FOUND;
    string dkim = NOT_FOUND;
    string dmarc = NOT_FOUND;
    if authenticationResults != NOT_FOUND {
        string results = authenticationResults.toLowerAscii();
        spf = results.includes("spf=pass") ? "pass"
            : (results.includes("spf=fail") ? "fail" : (results.includes("spf=neutral") ? "neutral" : "unknown"));
        dkim = results.includes("dkim=pass") ? "pass"
            : (results.includes("dkim=fail") ? "fail" : (results.includes("dkim=temperror") ? "error" : "unknown"));
        dmarc = results.includes("dmarc=pass") ? "pass" : (results.includes("dmarc=fail") ? "fail" : "unknown");
    } else {
        string? receivedSpf = headers["received-spf"];
        if receivedSpf is string {
            string value = receivedSpf.toLowerAscii();
            spf = value.includes("fail") ? "fail" : (value.includes("pass") ? "pass" : "unknown");
        }
        if headers.hasKey("dkim-signature") {
            dkim = "found";
        }
        string? dmarcHeader = headers["dmarc"];
        if dmarcHeader is string {
            string value = dmarcHeader.toLowerAscii();
            dmarc = value.includes("pass") ? "pass" : (value.includes("fail") ? "fail" : "unknown");
        }
    }

    string initialIP = findOriginatingIp(receivedHeaders) ?: IP_NOT_FOUND;
    string organization = "No Organization Found";
    string country = "No Country Found";
    string city = "No City Found";
    string ipSenderReputation = "Unknown";
    string recentSpamActivity = "Not associated with recent spam";

    if initialIP != IP_NOT_FOUND {
        json|error location = ipApiClient->get(string `/${initialIP}`);
        if location is map<json> {
            organization = textOrDefault(location["org"], organization);
            country = textOrDefault(location["country"], country);
            city = textOrDefault(location["city"], city);
        }

        json|error reputation = ipQualityScoreClient->get(string `/${ipQualityScoreApiKey}/${initialIP}?strictness=1&allow_public_access_points=true&lighter_penalties=true`);
        if reputation is map<json> {
            json score = reputation["fraud_score"];
            if score is int|float|decimal {
                float fraudScore = <float>score;
                ipSenderReputation = fraudScore >= 85.0 ? "Bad" : (fraudScore >= 75.0 ? "Poor"
                    : (fraudScore >= 50.0 ? "Suspicious" : (fraudScore >= 11.0 ? "OK" : "Good")));
                recentSpamActivity = fraudScore >= 85.0 ? "Identified spam in the last 48 hours"
                    : (fraudScore >= 75.0 ? "Identified spam in the last month" : "Not associated with recent spam");
            }
        }
    }

    return {
        messageId,
        subject: headers["subject"] ?: NOT_FOUND,
        sender: headers["from"] ?: NOT_FOUND,
        replyTo: headers["reply-to"] ?: NOT_FOUND,
        returnPath: headers["return-path"] ?: NOT_FOUND,
        spf,
        dkim,
        dmarc,
        authenticationResults,
        initialIP,
        organization,
        country,
        city,
        recentSpamActivity,
        ipSenderReputation
    };
}

# Finds the IP address that the email came from. It reads the oldest (bottom-most) Received header, ignores
# loopback and private IPv4 addresses, and takes the first IPv6 or IPv4 address left. If that header has no such
# address, for example because it records a hop inside the sender's own mail server, it moves up to the next header.
#
# + receivedHeaders - The Received headers, from the newest hop to the oldest hop
# + return - The IP address, or `()` if there is none
isolated function findOriginatingIp(string[] receivedHeaders) returns string? {
    foreach int i in int:range(receivedHeaders.length() - 1, -1, -1) {
        foreach regexp:Span span in re `[0-9A-Fa-f:\.]+`.findAll(receivedHeaders[i]) {
            string candidate = span.substring();
            while candidate.endsWith(".") {
                candidate = candidate.substring(0, candidate.length() - 1);
            }
            if isPublicIpv4(candidate) || isIpv6(candidate) {
                return candidate;
            }
        }
    }
    return ();
}

isolated function isPublicIpv4(string candidate) returns boolean {
    if !re `((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`.isFullMatch(candidate) {
        return false;
    }
    return !re `(127|10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\..*`.isFullMatch(candidate);
}

isolated function isIpv6(string candidate) returns boolean {
    string[] halves = re `::`.split(candidate);
    if halves.length() > 2 {
        return false;
    }
    int groups = 0;
    foreach string half in halves {
        if half == "" {
            continue;
        }
        foreach string group in re `:`.split(half) {
            if !re `[0-9A-Fa-f]{1,4}`.isFullMatch(group) {
                return false;
            }
            groups += 1;
        }
    }
    return halves.length() == 2 ? groups >= 2 && groups <= 7 : groups == 8;
}

isolated function textOrDefault(json value, string default) returns string {
    return value is string && value != "" ? value : default;
}
