import ballerinax/googleapis.gmail;
import ballerinax/jira;

// Normalize Jira base URL to ensure it ends with '/rest'
function normalizeJiraBaseUrl(string baseUrl) returns string {
    string normalizedUrl = baseUrl;
    
    // Remove any trailing slashes to avoid double-slash when appending paths.
    while normalizedUrl.endsWith("/") {
        normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length() - 1);
    }
    
    // If the URL ends with '/rest/api/3' (or '/rest/api/2'), normalize it back to just '/rest'.
    if normalizedUrl.endsWith("/rest/api/3") {
        normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length() - "/api/3".length());
    } else if normalizedUrl.endsWith("/rest/api/2") {
        normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length() - "/api/2".length());
    } else if !normalizedUrl.endsWith("/rest") {
        // If it doesn't already end with '/rest', append it.
        normalizedUrl = normalizedUrl + "/rest";
    }
    
    return normalizedUrl;
}

jira:ConnectionConfig config = {
    auth: {
        username: jiraEmail,
        password: jiraApiToken
    }
};

final string jiraApiBaseUrl = normalizeJiraBaseUrl(jiraBaseUrl);
final jira:Client jiraClient = check new (config, jiraApiBaseUrl);

gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshToken: gmailRefreshToken,
        clientId: gmailClientId,
        clientSecret: gmailClientSecret
    }
};

final gmail:Client gmailClient = check new (gmailConfig);
