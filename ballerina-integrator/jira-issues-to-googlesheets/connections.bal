import ballerinax/googleapis.sheets as sheets;
import ballerinax/jira;

final jira:Client jiraClient = check new (
    {
        auth: {
            username: jiraConfig.email,
            password: jiraConfig.apiToken
        }
    },
    jiraConfig.baseUrl
);

final sheets:Client sheetsClient = check new ({
    auth: {
        refreshToken: googleSheetsConfig.refreshToken,
        clientId: googleSheetsConfig.clientId,
        clientSecret: googleSheetsConfig.clientSecret,
        refreshUrl: sheets:REFRESH_URL
    }
});
