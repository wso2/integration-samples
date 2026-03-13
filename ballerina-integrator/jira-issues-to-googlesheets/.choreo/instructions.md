## What It Does

- Queries all Issue records from Jira using JQL (Jira Query Language)
- Creates a new Google Sheets spreadsheet with a timestamped name (e.g., "Jira Issues 2025-11-17 14:30")
- Appends all issue data to the spreadsheet with columns for Issue Key, Summary, Status, Assignee, Created date, and Due Date

<details>

<summary>Jira Setup Guide</summary>

1. A Jira Cloud account with API access
2. Basic Auth credentials:
  - Base URL (your Jira instance URL, e.g., `https://your-domain.atlassian.net`)
  - Email (your Jira account email)
  - API Token (generated from your Jira account)
  - Project Key (the key of the Jira project to query; e.g., "PROJ", "SUPPORT")

This integration uses basic authentication with email and API token. [Learn how to create a Jira API token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

The project key is usually shown in the URL when you open your project in Jira (e.g., in `https://your-domain.atlassian.net/jira/software/projects/PROJ/boards/1`, the project key is `PROJ`). You can also find it on the project sidebar or in the project settings.

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
    - Time frame to filter new issues. Possible values:
        - `YESTERDAY`
        - `LAST_WEEK`
        - `LAST_MONTH`
        - `LAST_QUARTER`
        - `ALL`
3. `spreadsheetId`: 
    - ID of an existing Google Sheets spreadsheet to append data to. Below is how to find the spreadsheet ID.
        - `https://docs.google.com/spreadsheets/d/<spreadsheetId>/`
        - Use this `spreadsheetId` as the value.
    - A new sheet will be created in the spreadsheet with a timestamped name.
    - If not provided, a new spreadsheet will be created.

</details>
