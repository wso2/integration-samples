# Salesforce Leads to Google Sheets Integration

A Ballerina automation integration that exports Salesforce Lead records to a Google Sheets spreadsheet on a configurable schedule.

## Description

This integration reads Salesforce Lead records and syncs them to Google Sheets on a schedule. It supports configurable filters, field mapping, sync modes, incremental tracking, and optional sheet splitting for reporting.

## What It Does

- Queries Salesforce Lead records using configurable filters (timeframe, custom SOQL conditions, and converted status)
- Maps selected Salesforce Lead fields to Google Sheets columns
- Creates a new timestamped spreadsheet or writes to an existing spreadsheet using the provided `spreadsheetId`
- Supports multiple sync modes: `APPEND`, `FULL_REPLACE`, and `UPSERT_BY_EMAIL`, including incremental sync with last-modified tracking
- Optionally splits leads into multiple sheets by a selected field value (for example, `LeadSource` or `Status`)

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

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Google Sheets Setup

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
3. Scopes required:
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required to connect to Salesforce and Google Sheets.

### Salesforce Credentials

- `salesforceRefreshToken` - Salesforce OAuth2 refresh token
- `salesforceClientId` - Salesforce OAuth2 client ID
- `salesforceClientSecret` - Salesforce OAuth2 client secret
- `salesforceRefreshUrl` - Salesforce OAuth2 token endpoint (for example, `https://login.salesforce.com/services/oauth2/token`)
- `salesforceBaseUrl` - Salesforce instance URL

### Google Credentials

- `googleRefreshToken` - Google OAuth2 refresh token
- `googleClientId` - Google OAuth2 client ID
- `googleClientSecret` - Google OAuth2 client secret

### Runtime Configurations

- `spreadsheetId` - Existing spreadsheet ID; if empty, a new spreadsheet is created
- `tabName` - Base worksheet name for output
- `fieldMapping` - Ordered Lead fields to export as columns
- `soqlFilter` - Additional SOQL condition fragment (without `WHERE`)
- `timeframe` - Date window filter (`ALL`, `YESTERDAY`, `LAST_WEEK`, `LAST_MONTH`, `LAST_YEAR`)
- `includeConverted` - Include converted leads when set to `true`
- `syncMode` - Sync strategy: `APPEND`, `FULL_REPLACE`, `UPSERT_BY_EMAIL`
- `enableIncrementalSync` and `lastSyncTimestamp` - Incremental sync controls
- `splitBy` - Split output across multiple sheets by a selected field
- `timezone` - Timezone used for timestamp generation
- `enableAutoFormat` - Enables built-in sheet formatting behavior

## Deploying on Devant

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Google Sheets credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, select a schedule frequency that matches your sync requirements.
8. Set the desired execution time and click **Update**.
9. Once tested, promote the integration to production and configure production environment variables.

## License

Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com)

Licensed under the Apache License, Version 2.0.
