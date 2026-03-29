configurable SalesforceConfig salesforceConfig = ?;

configurable GoogleConfig googleConfig = ?;

enum TimeFrame {
    YESTERDAY = "YESTERDAY",
    LAST_WEEK = "LAST_WEEK",
    LAST_MONTH = "LAST_MONTH",
    LAST_YEAR = "LAST_YEAR",
    ALL = "ALL"
}

enum SyncMode {
    APPEND = "APPEND",
    FULL_REPLACE = "FULL_REPLACE",
    UPSERT_BY_EMAIL = "UPSERT_BY_EMAIL"
}

configurable string timezone = "Asia/Colombo";
configurable string spreadsheetId = "";
configurable string tabName = "Leads";

configurable string[] fieldMapping = [
    "Id",
    "FirstName",
    "LastName",
    "Email",
    "Phone",
    "Company",
    "Title",
    "Status",
    "LeadSource",
    "Industry",
    "Rating",
    "CreatedDate",
    "LastModifiedDate"
];

configurable string soqlFilter = "";
configurable TimeFrame timeframe = ALL;
configurable boolean includeConverted = false;

configurable SyncMode syncMode = APPEND;
configurable boolean enableAutoFormat = true;
configurable string splitBy = "";
