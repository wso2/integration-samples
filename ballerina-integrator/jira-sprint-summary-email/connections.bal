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

jira:ConnectionConfig jiraConnectionConfig = {
    auth: {
        username: jira.email,
        password: jira.apiToken
    }
};

final string jiraApiBaseUrl = normalizeJiraBaseUrl(jira.baseUrl);
final jira:Client jiraClient = check new (jiraConnectionConfig, jiraApiBaseUrl);

gmail:ConnectionConfig gmailConnectionConfig = {
    auth: {
        refreshToken: gmail.refreshToken,
        clientId: gmail.clientId,
        clientSecret: gmail.clientSecret
    }
};

final gmail:Client gmailClient = check new (gmailConnectionConfig);
