# Salesforce to Google Sheets Integration

## Description

This integration extracts all Opportunity records from Salesforce and creates a spreadsheet in Google Sheets with key opportunity information. Each execution creates a new spreadsheet with a timestamp, providing a historical snapshot of your opportunities over time.

### What It Does

- Queries all Opportunity records from Salesforce using SOQL
- Creates a new Google Sheets spreadsheet with a timestamped name (e.g., "Opportunities 2025-11-17 14:30")
- Exports the following Opportunity fields:
  - ID
  - Name
  - Amount
  - Owner ID
  - Last Activity Date
  - Description
  - Probability
  - Next Step
- Appends all opportunity data to the spreadsheet

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
3. Scopes Required
  - `https://www.googleapis.com/auth/drive`
  - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required to connect to Salesforce and Google Sheets.

### Salesforce Credentials

- `salesforceRefreshToken` - Your Salesforce OAuth2 refresh token
- `salesforceClientId` - Your Salesforce OAuth2 client ID
- `salesforceClientSecret` - Your Salesforce OAuth2 client secret
- `salesforceRefreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://your-instance.salesforce.com/services/oauth2/token`)
- `salesforceBaseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)

### Google Credentials

- `googleRefreshToken` - Your Google OAuth2 refresh token
- `googleClientId` - Your Google OAuth2 client ID
- `googleClientSecret` - Your Google OAuth2 client secret

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Google Sheets credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, select **Week** from the dropdown.
8. Set the desired day and time for the integration to run weekly and click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.