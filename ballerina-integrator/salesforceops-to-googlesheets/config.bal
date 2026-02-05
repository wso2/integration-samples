configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
} salesforceConfig = ?;

configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
} googleConfig = ?;

configurable string timezone = "Asia/Colombo";
configurable string? spreadsheetId = ();

enum TimeFrame {
    YESTERDAY = "YESTERDAY",
    LAST_WEEK = "LAST_WEEK",
    LAST_MONTH = "LAST_MONTH",
    LAST_QUARTER = "LAST_QUARTER",
    ALL = "ALL"
};

configurable TimeFrame timeFrame = "ALL";
