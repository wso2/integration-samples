configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
} salesforceConfig = ?;

configurable record {
    string mandrilApiKey;

} mailchimpConfig = ?;

configurable record {
    string fromEmail;
    string fromName = "Salesforce Performance Report";
    string[] recipientEmails;
    string subjectTemplate = "Monthly Salesforce Performance Summary - {{month}} {{year}}";
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

