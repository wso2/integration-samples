type JiraConfig record {|
    string baseUrl;
    string email;
    string apiToken;
    string projectKey;
|};

type GoogleSheetsConfig record {|
    string refreshToken;
    string clientId;
    string clientSecret;
|};

configurable JiraConfig jiraConfig = ?;

configurable GoogleSheetsConfig googleSheetsConfig = ?;

configurable string timezone = "UTC";

configurable string? spreadsheetId = ();

public enum TimeFrame {
    ALL,
    YESTERDAY,
    LAST_WEEK,
    LAST_MONTH,
    LAST_QUARTER
}

configurable TimeFrame timeFrame = ALL;
