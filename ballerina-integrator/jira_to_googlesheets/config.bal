configurable record {
    string baseUrl;
    string email;
    string apiToken;
    string projectKey;
} jiraConfig = ?;

configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
} googleSheetsConfig = ?;

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
