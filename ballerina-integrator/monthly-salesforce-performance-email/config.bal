
configurable string salesforceBaseUrl = ?;
configurable string salesforceClientId = ?;
configurable string salesforceClientSecret = ?;
configurable string salesforceRefreshToken = ?;
configurable string salesforceRefreshUrl = ?;

configurable string mailchimpApiKey = ?;

configurable int scheduleDayOfMonth = 1;

configurable string salesforceReportId = ?;
configurable string timePeriod = "monthly";
configurable string[] recipientEmails = [];
configurable string emailSubjectTemplate = "Monthly Salesforce Performance Summary - {{month}} {{year}}";
configurable string comparisonPeriod = "MoM";
configurable string filterByTeam = "";
configurable string filterByTerritory = "";
configurable string filterByOwner = "";

configurable string fromEmail = ?;
configurable string fromName = "Salesforce Performance Report";

configurable decimal targetRevenue = 0.0;
configurable int targetDealsCount = 0;
configurable decimal targetPipelineValue = 0.0;

configurable boolean includePerRepBreakdown = false;
