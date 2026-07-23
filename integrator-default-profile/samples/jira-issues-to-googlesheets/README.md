# Jira to Google Sheets Integration

## Description

This integration extracts Jira issues from a specified project using JQL (Jira Query Language) and creates a spreadsheet in Google Sheets with key issue information. Each execution creates a new spreadsheet with a timestamp, providing a historical snapshot of your project's status over time.

### What It Does

- **Queries Jira issues** from a specific project (e.g., `project=PROJ`), optionally filtered by timeFrame (e.g., issues created in the last 7 days)
- **Creates or updates Google Sheets:**
  - Creates a new timestamped Google Sheets spreadsheet if `spreadsheetId` is not provided
  - Appends a new timestamped sheet to an existing spreadsheet if `spreadsheetId` is provided
- **Exports the following Jira fields:**
    - Issue Key
    - Summary
    - Status
    - Assignee
    - Created Date
    - Due Date

- **Timestamps** are generated in the configured timezone (default:UTC)

## Prerequisites

Before running this integration, you need:

### Jira Setup

1.  **A Jira Cloud account**
2.  **API Credentials:**
    * **Email:** Your Jira account email
    * **API Token:** A token generated from your [Atlassian account security settings](https://id.atlassian.com/manage-profile/security/api-tokens)
    * **Base URL:** Your Jira instance URL (e.g., `https://your-domain.atlassian.net`)
    * **Jira project key:** The project key is usually shown in the URL when you open your project in Jira (e.g., in `https://your-domain.atlassian.net/jira/software/projects/PROJ/boards/1`, the project key is `PROJ`). You can also find it on the project sidebar or in the project settings.

### Google Sheets Setup

1.  **A Google Cloud project** with Google Sheets API enabled
2.  **OAuth2 credentials:**
    * Client ID
    * Client Secret
    * Refresh Token
3.  **Scopes Required:**
    * `https://www.googleapis.com/auth/spreadsheets`
    * `https://www.googleapis.com/auth/drive`

> This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required to connect to Jira and Google Sheets. Create a `Config.toml` file or set environment variables.

### Jira Credentials

* `email` - Your Jira account email address
* `apiToken` - Your Jira API token
* `baseUrl` - Your Jira instance URL
* `jiraProjectKey` - The key of the project you want to export

### Google Credentials

* `refreshToken` - Your Google OAuth2 refresh token
* `clientId` - Your Google OAuth2 client ID
* `clientSecret` - Your Google OAuth2 client secret

## Deploying on WSO2 Integration Platform

1.  **Sign in** to your [WSO2 Integration Platform account](https://wso2.com/devant/).
2.  **Create a new Integration** and follow instructions in the [Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3.  **Select the Technology** as `WSO2 Integrator: BI`.
4.  **Choose the Integration Type** as `Automation` and click **Create**.
5.  Once the build is successful, click **Configure to Continue** and set up the required environment variables for Jira and Google Sheets credentials.
6.  Click **Schedule** to schedule the automation.
7.  In the **BY INTERVAL** tab, select **Week** from the dropdown.
8.  Set the desired day and time for the integration to run weekly and click Update.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
