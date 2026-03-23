// HubSpot Configuration
configurable string hubspotAccessToken = ?;

// Google Sheets OAuth Configuration
configurable string googleClientId = ?;
configurable string googleClientSecret = ?;
configurable string googleRefreshToken = ?;
configurable string googleRefreshUrl = "https://oauth2.googleapis.com/token";

// Google Sheet Details
configurable string spreadsheetId = ?;

// Lifecycle-based Sheet Routing Configuration
// Each lifecycle stage maps to a sheet name.
// Set multiple stages to the same name to merge them into one sheet.
configurable string subscriberSheetName = "Subscribers";
configurable string leadSheetName = "Leads";
configurable string marketingqualifiedleadSheetName = "MQLs";
configurable string salesqualifiedleadSheetName = "SQLs";
configurable string opportunitySheetName = "Opportunities";
configurable string customerSheetName = "Customers";
configurable string evangelistSheetName = "Evangelists";
configurable string otherSheetName = "Others";
configurable string defaultSheetName = "Sheet1";

// Field Mapping Configuration
configurable string[] fields = ["email", "firstname", "lastname", "phone"];

// Incremental Sync Configuration
configurable string lastSyncTimestamp = "";

// Optional Contact Filter Configuration
configurable string contactFilterProperty = "";
configurable string contactFilterValue = "";

// Row Limit Configuration
configurable int maxRows = 2;

// Sync Mode Configuration
// "upsert"  - Update existing row if email matches, insert if not (default)
// "append"  - Always insert a new row, never check for duplicates
// "replace" - Clear the sheet first, then write all contacts fresh
configurable string syncMode = "upsert";
