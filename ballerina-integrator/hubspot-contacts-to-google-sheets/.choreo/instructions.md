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
2. Go to Settings > Integrations > Private Apps.
3. Create a private app and enable the scope `crm.objects.contacts.read`.
4. Copy the generated access token.
5. Use that token as `hubspotAccessToken` in the integration configuration.

</details>

<details>
<summary>Google Sheets Setup</summary>

1. Create or select a Google Cloud project.
2. Enable Google Sheets API for the project.
3. Create OAuth 2.0 credentials (Web application).
4. Add this redirect URI: `https://developers.google.com/oauthplayground`.
5. In OAuth Playground, use your own OAuth credentials and authorize scope `https://www.googleapis.com/auth/spreadsheets`.
6. Exchange the authorization code and copy the refresh token.
7. Use `googleClientId`, `googleClientSecret`, and `googleRefreshToken` in the integration configuration.

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
