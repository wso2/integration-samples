configurable record {
    string refreshToken;
    string clientId;
    string clientSecret;
    string refreshUrl;
    string baseUrl;
    string reportId;
} salesforceConfig = ?;

configurable record {
    string mandrillApiKey;
    string fromEmail;
    string fromName?;
    string[] recipientEmails;
    string subjectTemplate?;
} mailchimpConfig = ?;

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

