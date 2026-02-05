## What It Does

- Queries all Opportunity records from Salesforce using SOQL
- Creates a new Google Sheets spreadsheet with a timestamped name (e.g., "Opportunities 2025-11-17 14:30")
- Appends all opportunity data to the spreadsheet

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

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

<summary>Additional Configurations</summary>

1. `timeZone`
    - Time zone to be used for timestamping the spreadsheet name (e.g., "America/New_York")
2. `timeFrame`: 
    - Time frame to filter new opportunities. Possible values:
        - `YESTERDAY`
        - `LAST_WEEK`
        - `LAST_MONTH`
        - `LAST_QUARTER`
        - `ALL` (default)
3. `spreadsheetId`: 
    - ID of an existing Google Sheets spreadsheet to append data to. Below is how to find the spreadsheet ID.
        - `https://docs.google.com/spreadsheets/d/<spreadsheetId>/`
        - Use this `spreadsheetId` as the value.
    - A new sheet will be created in the spreadsheet with a timestamped name.
    - If not provided, a new spreadsheet will be created.

</details>