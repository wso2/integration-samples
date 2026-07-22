# HubSpot Contacts to Google Sheets

## What It Does

- Fetches contacts from HubSpot CRM Contacts API
- Routes contacts to sheet tabs based on lifecycle stage
- Upserts rows using email as the unique key
- Supports incremental sync and optional filtering
- Runs once per execution (scheduling is handled externally)

<details>
<summary>HubSpot Setup</summary>

1. Sign in to HubSpot.
2. Go to Settings > Integrations > Legacy Apps.
3. Create a Legacy app and enable the scope `crm.objects.contacts.read`.
4. Obtain the generated access token.

</details>

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
<summary>Spreadsheet Setup</summary>

1. Create a Google Spreadsheet.
2. Copy the spreadsheet ID from `https://docs.google.com/spreadsheets/d/<spreadsheetId>/edit`.
3. Use that value as `spreadsheetId`.
4. The integration creates missing lifecycle-stage tabs automatically.

Default sheet mapping:

- Subscriber -> `Subscribers`
- Lead -> `Leads`
- Marketing Qualified Lead -> `MQLs`
- Sales Qualified Lead -> `SQLs`
- Opportunity -> `Opportunities`
- Customer -> `Customers`
- Evangelist -> `Evangelists`
- Other -> `Others`
- Unrecognized/empty -> `Sheet1`

</details>

<details>
<summary>Additional Configuration</summary>

- `fields`: HubSpot properties exported as columns
- `syncMode`: `upsert` (default), `append`, or `replace`
- `maxRows`: max contacts per run (`0` means unlimited)
- `lastSyncTimestamp`: optional initial checkpoint
- `contactFilterProperty` / `contactFilterValue`: optional HubSpot filter

</details>
