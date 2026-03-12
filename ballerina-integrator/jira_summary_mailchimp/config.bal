configurable record {
    string username;
    string password;
    string domain;

    string jqlQuery;
} jiraConfig = ?;

configurable record {
    string mandrillApiKey;

    string fromEmail;
    string fromName;

    string[] recipients;
} mailchimpConfig = ?;

configurable int maxIssuesToDisplay = 5;
