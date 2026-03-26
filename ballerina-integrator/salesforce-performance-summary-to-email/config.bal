configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
} salesforceConfig = ?;

configurable record {
    string mandrillApiKey;

} mailchimpConfig = ?;

configurable record {
    string fromEmail;
    string fromName?;
    string[] recipientEmails;
    string subjectTemplate?;
} emailConfig = ?;

configurable string salesforceReportId = ?;

enum TimePeriod {
    MONTHLY = "monthly",
    QUARTERLY = "quarterly",
    YEARLY = "yearly"
};

configurable TimePeriod timePeriod = MONTHLY;

enum ComparisonPeriod {
    MOM = "MoM",
    YOY = "YoY"
};

configurable ComparisonPeriod comparisonPeriod = MOM;

configurable boolean includePerRepBreakdown = false;

