# Setup Instructions

Follow these instructions to configure and deploy the Salesforce Leads to Google Sheets integration on WSO2 Devant.

## What It Does

- Fetches Salesforce Lead records with configurable filters and export field selection
- Writes results to Google Sheets by creating a new spreadsheet or targeting an existing one
- Supports `APPEND`, `FULL_REPLACE`, and `UPSERT_BY_EMAIL` sync behaviors
- Can run incremental syncs using `LastModifiedDate` and `lastSyncTimestamp`
- Can split output into multiple sheets using a selected lead field such as `LeadSource` or `Status`

<details>
<summary>Salesforce Setup Guide</summary>

1. Create a Salesforce Connected App with OAuth enabled.
2. Collect these values from Salesforce:
  - Client ID (`Consumer Key`)
  - Client Secret (`Consumer Secret`)
  - Refresh Token
  - Refresh URL (token endpoint)
  - Base URL (your Salesforce instance URL)
3. Ensure the app has OAuth scopes for API access and refresh token usage.

This integration uses refresh-token OAuth flow for Salesforce authentication. [Salesforce OAuth setup reference](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>
<summary>Google Sheets Setup Guide</summary>

1. Create a Google Cloud project and enable:
  - Google Sheets API
  - Google Drive API
2. Create OAuth credentials and collect:
  - Client ID
  - Client Secret
  - Refresh Token
3. Confirm access includes these scopes:
  - `https://www.googleapis.com/auth/drive`
  - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh-token OAuth flow for Google APIs. [Google Workspace development guide](https://developers.google.com/workspace/guides/get-started).

</details>

<details>
<summary>Additional Configurations</summary>

1. `timezone`
  - IANA timezone used for timestamp formatting (e.g., `Asia/Colombo`, `America/New_York`).

2. `timeframe`
  - Lead creation timeframe filter.
  - Allowed values: `ALL`, `YESTERDAY`, `LAST_WEEK`, `LAST_MONTH`, `LAST_YEAR`.

3. `spreadsheetId`
  - Existing spreadsheet ID to write into.
  - You can extract it from `https://docs.google.com/spreadsheets/d/<spreadsheetId>/edit`.
  - If empty, a new spreadsheet is created per run.

4. `tabName`
  - Base worksheet name for the export.

5. `fieldMapping`
  - Ordered list of Salesforce Lead fields mapped to output columns.

6. `soqlFilter`
  - Custom SOQL `WHERE` fragment (without `WHERE`) for advanced filtering.

7. `syncMode`
  - Output write strategy: `APPEND`, `FULL_REPLACE`, `UPSERT_BY_EMAIL`.

8. `includeConverted`
  - Set `true` to include converted leads in results.

9. `enableIncrementalSync` and `lastSyncTimestamp`
  - Use together to fetch only leads modified after a given timestamp.

10. `splitBy`
  - Splits rows into separate sheets by a chosen field (e.g., `Status`, `LeadSource`).

11. `enableAutoFormat`
  - Toggles automatic sheet formatting behaviors used by the integration.

</details>

## Deployment Steps

1. Configure Salesforce and Google OAuth values in the integration runtime configuration.
2. Set optional parameters (`syncMode`, `spreadsheetId`, filters, and mapping) based on your use case.
3. Configure the schedule in Devant (for example: hourly, daily, or weekly).
4. Deploy the integration and verify execution logs.

## Troubleshooting

### Authentication Failures
- Re-check client credentials, refresh tokens, and token endpoints.
- Confirm APIs/scopes are enabled for both providers.

### No Records Exported
- Verify `soqlFilter`, `timeframe`, `includeConverted`, and `lastSyncTimestamp` values.
- Check Salesforce-side data availability and permissions.

### Spreadsheet Write Issues
- Confirm `spreadsheetId` is valid and accessible by the authenticated Google account.
- Validate `syncMode` expectations for sheet creation/replacement behavior.

### Performance Tuning
- Reduce `fieldMapping` columns.
- Use incremental sync and tighter filters.
- Use `splitBy` carefully when record volume is high.
