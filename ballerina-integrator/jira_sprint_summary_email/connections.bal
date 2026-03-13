import ballerinax/googleapis.gmail;
import ballerinax/jira;

jira:ConnectionConfig config = {
    auth: {
        username: jiraEmail,
        password: jiraApiToken
    }
};

final string jiraApiBaseUrl = jiraBaseUrl.endsWith("/rest") ? jiraBaseUrl : jiraBaseUrl + "/rest";
final jira:Client jiraClient = check new (config, jiraApiBaseUrl);

gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshToken: gmailRefreshToken,
        clientId: gmailClientId,
        clientSecret: gmailClientSecret
    }
};

final gmail:Client gmailClient = check new (gmailConfig);
