# Salesforce Performance Summary Email Automation

## Description

This automation extracts performance metrics from Salesforce Analytics reports and sends formatted email summaries to stakeholders via Mailchimp Transactional. Each execution compares current period performance against a previous period (Month-over-Month or Year-over-Year), providing insights into revenue, deals, pipeline value, and performance trends.

### What It Does

- Executes a specified Salesforce Analytics report using the Analytics REST API
- Calculates current and previous period date ranges based on configuration (monthly, quarterly, or yearly)
- Extracts pre-aggregated metrics from Salesforce report fact maps (Sum, Average, Count, etc.)
- Compares current period performance against previous period
- Calculates percentage changes and trends for all metrics
- Generates a professional HTML email with:
  - Dynamic metric cards with color-coded change indicators
  - Comparison charts
  - Optional sales rep performance breakdown
- Sends the formatted email to configured recipients via Mailchimp Transactional

## Prerequisites

Before running this automation, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. An existing Salesforce Analytics Report ID (e.g., `00O5g000007QtXXEA0`)
3. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)

This automation uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Mailchimp Transactional Setup

1. A Mailchimp Transactional (Mandrill) account
2. API Key from Mailchimp Transactional

[Learn how to get Mailchimp Transactional API Keys](https://mailchimp.com/developer/transactional/guides/quick-start/#generate-your-api-key).

## Configuration

The following configurations are required to connect to Salesforce and Mailchimp Transactional.

### Salesforce Credentials

- `refreshToken` - Your Salesforce OAuth2 refresh token
- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret
- `refreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://login.salesforce.com/services/oauth2/token`)
- `baseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)

### Mailchimp Credentials

- `mandrilApiKey` - Your Mailchimp Transactional API key

### Email Configuration

- `fromEmail` - Sender email address
- `fromName` - Sender display name (default: "Salesforce Performance Report")
- `recipientEmails` - Array of email addresses to receive the report
- `subjectTemplate` - Email subject template (default: "Monthly Salesforce Performance Summary - {{month}} {{year}}")

### Report Configuration

- `salesforceReportId` - Required: Salesforce Analytics Report ID
- `timePeriod` - Report period: `monthly` (default), `quarterly`, or `yearly`
- `comparisonPeriod` - Comparison type: `MoM` (default) or `YoY`
- `includePerRepBreakdown` - Include per-rep performance breakdown (default: false)

## Deploying on **WSO2 Integration Platform**

1. Sign in to your WSO2 Integration Platform account.
2. Create a new Integration and follow instructions in the [Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up all required configuration values, including Salesforce credentials, Mailchimp credentials, `salesforceReportId`, and the email sender/recipient settings.
6. Click **Schedule** to schedule the automation.
7. Choose a schedule cadence that matches `timePeriod`:
   - `monthly`: run once per month
   - `quarterly`: run once per quarter
   - `yearly`: run once per year
8. Set the desired execution time and click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
