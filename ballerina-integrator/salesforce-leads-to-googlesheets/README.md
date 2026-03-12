# Salesforce Opportunities to Google Sheets Integration

A Ballerina automation integration that exports Salesforce Opportunity records to a Google Sheets spreadsheet on a configurable schedule.

## Description

This integration extracts all Opportunity records from Salesforce and creates a spreadsheet in Google Sheets with key opportunity information. Each execution creates a new spreadsheet with a timestamp, providing a historical snapshot of your opportunities over time.

## What It Does

- Queries Salesforce Opportunity records using customizable SOQL filters
- Maps selected Salesforce Opportunity fields to Google Sheets columns
- Creates a new Google Sheets spreadsheet with a timestamped name (e.g., "Salesforce Leads 2025-01-17 14:30")
- Optionally appends to an existing spreadsheet as a new sheet
- Handles timezone conversion for spreadsheet naming
- Provides detailed logging of export operations
- Supports multiple sync modes (APPEND, FULL_REPLACE, UPSERT_BY_EMAIL)
- Enables filtering by timeframe and custom SOQL conditions

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for authentication. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Google Sheets Setup

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
3. Scopes Required:
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for authentication. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required to connect to Salesforce and Google Sheets.

### Salesforce Credentials

- **`salesforceRefreshToken`** - Your Salesforce OAuth2 refresh token
- **`salesforceClientId`** - Your Salesforce OAuth2 client ID
- **`salesforceClientSecret`** - Your Salesforce OAuth2 client secret
- **`salesforceRefreshUrl`** - Salesforce OAuth2 token endpoint (e.g., `https://login.salesforce.com/services/oauth2/token`)
- **`salesforceBaseUrl`** - Your Salesforce instance URL (e.g., `https://yourinstance.salesforce.com`)

### Google Credentials

- **`googleRefreshToken`** - Your Google OAuth2 refresh token
- **`googleClientId`** - Your Google OAuth2 client ID
- **`googleClientSecret`** - Your Google OAuth2 client secret

### Optional Configurations

#### Spreadsheet Settings
- **`spreadsheetId`** (string, default: `""`)  
  Target Google Spreadsheet ID. If empty, creates a new spreadsheet each run.  
  Example: `"1abc123xyz456def789ghi012jkl345mno678pqr"`

- **`tabName`** (string, default: `"Leads"`)  
  Name of the sheet tab within the spreadsheet

- **`timezone`** (string, default: `"UTC"`)  
  IANA timezone for timestamp formatting in spreadsheet names  
  Examples: `"America/New_York"`, `"Asia/Colombo"`, `"Europe/London"`

#### Field Mapping
- **`fieldMapping`** (string[], default: see below)  
  Ordered list of Salesforce Lead field API names to export as columns

**Default Field Mapping:**
```toml
fieldMapping = [
    "Id", "FirstName", "LastName", "Email", "Phone", 
    "Company", "Title", "Status", "LeadSource", "Industry", 
    "Rating", "CreatedDate", "LastModifiedDate"
]
```

#### Filtering Options
- **`soqlFilter`** (string, default: `""`)  
  Custom SOQL WHERE clause for filtering leads  
  Example: `"Rating = 'Hot' AND LeadSource = 'Web'"`

- **`timeframe`** (string, default: `"ALL"`)  
  Preset timeframe filter based on CreatedDate  
  Options: `"ALL"`, `"YESTERDAY"`, `"LAST_WEEK"`, `"LAST_MONTH"`, `"LAST_YEAR"`

- **`includeConverted`** (boolean, default: `false`)  
  Whether to include leads that have been converted to contacts/accounts

#### Sync Settings
- **`syncMode`** (string, default: `"APPEND"`)  
  How data is written to the spreadsheet  
  Options: `"APPEND"`, `"FULL_REPLACE"`, `"UPSERT_BY_EMAIL"`

- **`enableIncrementalSync`** (boolean, default: `false`)  
  Only fetch leads modified since last sync (reduces API calls)

- **`lastSyncTimestamp`** (string, default: `""`)  
  Last sync timestamp in ISO 8601 format  
  Example: `"2025-01-17T10:30:00Z"`  
  Used when `enableIncrementalSync` is `true`

#### Advanced Features
- **`enableAutoFormat`** (boolean, default: `true`)  
  Prepare sheets with headers in first row for optimal viewing

- **`splitBy`** (string, default: `""`)  
  Split leads into multiple sheets by field value  
  Examples: `"LeadSource"`, `"Status"`, `"Industry"`  
  Leave empty to disable

**Default Field Mapping:**
```
["Id", "FirstName", "LastName", "Email", "Phone", "Company", "Title", "Status", "LeadSource", "Industry", "Rating", "CreatedDate", "LastModifiedDate"]
```

**SOQL Filtering:**

Use the `soqlFilter` parameter to add custom WHERE clause conditions to filter leads. This provides maximum flexibility for complex queries.

**Examples:**
- Single condition: `soqlFilter = "Rating = 'Hot'"`
- Multiple conditions: `soqlFilter = "Rating = 'Hot' AND LeadSource = 'Web'"`
- Date filters: `soqlFilter = "CreatedDate > 2025-01-01"`
- Complex queries: `soqlFilter = "(Rating = 'Hot' OR Rating = 'Warm') AND Industry = 'Technology'"`

**Filtering Options:**

The integration provides multiple ways to filter leads:

**1. Timeframe Filter** (`timeframe` parameter):
Filter leads by when they were created using preset timeframes:
- `"ALL"` (default) - No timeframe filtering, fetch all leads
- `"YESTERDAY"` - Leads created yesterday
- `"LAST_WEEK"` - Leads created last week (Monday to Sunday)
- `"LAST_MONTH"` - Leads created last month
- `"LAST_YEAR"` - Leads created last year

**Example:**
```toml
timeframe = "LAST_WEEK"  # Only fetch leads created last week
```

**2. Custom SOQL Filter** (`soqlFilter` parameter):
Add custom WHERE clause conditions for advanced filtering:
```toml
soqlFilter = "Rating = 'Hot' AND LeadSource = 'Web'"
```

**3. Include Converted Leads** (`includeConverted` parameter):
```toml
includeConverted = true  # Include converted leads (default is false)
```

**Combining Filters:**
All filters work together. For example:
```toml
timeframe = "LAST_MONTH"
soqlFilter = "Rating = 'Hot'"
includeConverted = false
```
This fetches only unconverted hot leads created last month.

**Sync Modes:**

The integration supports three sync modes. Choose based on your use case:

**1. APPEND Mode (Default)**
- **What it does**: Creates a new sheet with a timestamped name and adds the lead data
- **When to use**: 
  - Building a historical log of all leads over time as separate sheets
  - You want to keep snapshots of leads from different time periods
  - Creating a new spreadsheet OR adding to an existing one
- **Requirements**: None (works with or without `spreadsheetId`)
- **Behavior**: 
  - With `spreadsheetId`: Creates a new sheet named "{tabName} {timestamp}" in the existing spreadsheet
  - Without `spreadsheetId`: Creates a new spreadsheet named "Salesforce Leads {timestamp}" with a sheet named "{tabName} {timestamp}"
  - Each run creates a new sheet with headers + data
- **Example use case**: Daily export creating separate sheets like "Leads 2025-01-17 09:00", "Leads 2025-01-18 09:00", etc.

**2. FULL_REPLACE Mode**
- **What it does**: Completely replaces the entire spreadsheet with fresh data from Salesforce
- **When to use**:
  - You want a current snapshot that gets refreshed each run (not historical data)
  - You need a clean spreadsheet with only the latest data
  - You want to remove all old sheets and start fresh
- **Requirements**: None (works with or without `spreadsheetId`)
- **Behavior**:
  - Without `spreadsheetId`: Creates a new spreadsheet named "Salesforce Leads {timestamp}" with a sheet named "{tabName}"
  - With `spreadsheetId`: **DELETES ALL EXISTING SHEETS** in the spreadsheet and creates a single new sheet named "{tabName}" with fresh data
  - ⚠️ **Warning**: This mode is destructive when used with an existing spreadsheet - all sheets will be permanently deleted
  - Writes fresh headers + current data
- **Example use case**: Weekly refresh where you want only the latest leads, removing all previous data and sheets

**3. UPSERT_BY_EMAIL Mode**
- **What it does**: Updates existing leads (matched by email) and adds new ones
- **When to use**:
  - You want to keep data up-to-date without duplicates
  - You need to track changes to existing leads
  - You're syncing the same leads repeatedly
- **Requirements**:
  - ⚠️ **MUST provide `spreadsheetId`** (requires existing spreadsheet to compare data)
  - ⚠️ **MUST include "Email" in `fieldMapping`**
  - Leads are matched by email address
- **Behavior**:
  - If email exists: Updates that row with new data
  - If email is new: Appends as new row
  - If no email: Appends as new row
- **Example use case**: Daily sync to keep lead status and details current

**Quick Decision Guide:**

| Scenario | Recommended Mode | Requires spreadsheetId? |
|----------|------------------|-------------------------|
| Creating new spreadsheet each time | `APPEND` or `FULL_REPLACE` | No |
| Want historical log as separate sheets | `APPEND` | No (or Yes for existing spreadsheet) |
| Want to add timestamped sheets to existing spreadsheet | `APPEND` | **Yes** |
| Want to completely replace entire spreadsheet | `FULL_REPLACE` | **Yes** |
| Regularly refresh with only latest data (delete old sheets) | `FULL_REPLACE` | **Yes** |
| Want to update existing leads, avoid duplicates | `UPSERT_BY_EMAIL` | **Yes** |
| Syncing same leads daily to track changes | `UPSERT_BY_EMAIL` | **Yes** |

**Advanced Features:**

**Incremental Sync:**
When `enableIncrementalSync` is enabled, only leads modified since `lastSyncTimestamp` are fetched. This reduces API calls and data transfer.
- Set `enableIncrementalSync = true`
- After each sync, check logs for the next timestamp to use
- Update `lastSyncTimestamp` with the logged value for the next run
- Example: `lastSyncTimestamp = "2025-01-17T10:30:00Z"`

**Auto-Formatting:**
When `enableAutoFormat` is enabled, the integration prepares sheets for optimal viewing:
- Headers are placed in the first row
- Sheet structure is optimized for manual formatting
- Note: Manual bold formatting and row freezing can be applied in Google Sheets UI

**Multi-Sheet Split:**
When `splitBy` is configured, leads are automatically organized into separate sheets:
- Set `splitBy` to a field name from `fieldMapping` (e.g., "LeadSource", "Status", "Industry")
- Each unique value creates a separate sheet named "{tabName} - {value}"
- Example: If `splitBy = "Status"`, creates sheets like "Leads - Open", "Leads - Contacted", etc.
- Works with all sync modes (APPEND, FULL_REPLACE, UPSERT_BY_EMAIL)

## Deploying on Devant

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Google Sheets credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, select **Week** from the dropdown.
8. Set the desired day and time for the integration to run weekly and click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.

## Getting Your Spreadsheet ID (Optional)

To use an existing Google Spreadsheet:

1. Open your Google Spreadsheet in a browser
2. Look at the URL in the address bar
3. The spreadsheet ID is the long string between `/d/` and `/edit`

**Example URL:**
```
https://docs.google.com/spreadsheets/d/1abc123xyz456def789ghi012jkl345mno678pqr/edit#gid=0
                                      ↑_____________________________________↑
                                              This is your spreadsheet ID
```

4. Copy this ID and use it in your `spreadsheetId` configuration

**Note:** If you don't provide a spreadsheet ID (or leave it empty), the integration will automatically create a new spreadsheet with a timestamped name each time it runs.

## License

Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com)

Licensed under the Apache License, Version 2.0.
