## What It Does

- Fetches Salesforce Lead records with configurable filters and export field selection
- Writes results to Google Sheets by creating a new spreadsheet or targeting an existing one
- Supports `APPEND`, `FULL_REPLACE`, and `UPSERT_BY_EMAIL` sync behaviors
- Can run incremental syncs using `LastModifiedDate` and `lastSyncTimestamp`
- Can split output into multiple sheets using a selected lead field such as `LeadSource` or `Status`

<details>
<summary>Salesforce Setup Guide</summary>

1. Salesforce account with API access
2. OAuth2 credentials:
  - Client ID 
  - Client Secret 
  - Refresh Token
  - Refresh URL 
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

<details>

<summary>Google Sheets Setup Guide</summary>

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
3. Scopes Required
  - `https://www.googleapis.com/auth/drive`
  - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

</details>

<details>
<summary>Additional Configurations</summary>

1. `timezone`
  - IANA timezone used for timestamp formatting.
  - Default: `"UTC"`.
  - If omitted, timestamps are formatted in `UTC` automatically.
  - Example: `timezone: "UTC"`.
  - Other examples: `Asia/Colombo`, `America/New_York`.

2. `timeframe`
  - Lead creation timeframe filter.
  - Default: `ALL`.
  - Allowed values: `ALL`, `YESTERDAY`, `LAST_WEEK`, `LAST_MONTH`, `LAST_YEAR`.

3. `spreadsheetId`
  - Existing spreadsheet ID to write into.
  - You can extract it from `https://docs.google.com/spreadsheets/d/<spreadsheetId>/edit`.
  - If empty, a new spreadsheet is created per run.

4. `tabName`
  - Base worksheet name for the export.

5. `fieldMapping`
  - Optional ordered array of Salesforce Lead field names mapped to output columns.
  - Default order: `Id`, `FirstName`, `LastName`, `Email`, `Phone`, `Company`, `Title`, `Status`, `LeadSource`, `Industry`, `Rating`, `CreatedDate`, `LastModifiedDate`.
  - Example: `["Id", "FirstName", "LastName", "Email"]`.

6. `soqlFilter`
  - Custom SOQL `WHERE` fragment (without `WHERE`) for advanced filtering.

7. `syncMode`
  - Output write strategy: `APPEND`, `FULL_REPLACE`, `UPSERT_BY_EMAIL`. Default: `APPEND`.

8. `includeConverted`
  - Set `true` to include converted leads in results. Default: `false` (converted leads are excluded when unset).

9. `enableIncrementalSync` and `lastSyncTimestamp`
  - Use together to fetch only leads modified after a given timestamp.

10. `splitBy`
  - Splits rows into separate sheets by a chosen field (e.g., `Status`, `LeadSource`).
  - Default: `""` (no splitting).
  - When empty or unset, all rows are written to the primary sheet instead of separate sheets.
  - Example: `splitBy: "Status"` creates separate sheets per status, while `splitBy: ""` keeps all rows in a single sheet.

11. `enableAutoFormat`
  - Default: `true`.
  - Enables the integration's sheet-formatting hook.
  - Current behavior logs formatting guidance and keeps headers in the first row.
  - It does not currently auto-apply header bolding/background, top-row freezing, column auto-fit, number/date formatting, or alternating row styling.

</details>
