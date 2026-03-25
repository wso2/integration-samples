# Jira Sprint Summary Email Integration

## Description
This integration checks a Jira project for recently completed sprints and automatically sends detailed email summaries to your team via Gmail. When executed, it searches for sprints completed within a configurable lookback window, generates comprehensive HTML reports with metrics and issue breakdowns, and emails them to configured recipients. The integration uses Jira labels to track processed sprints and prevent duplicate notifications. Designed to be run on a schedule via cron jobs or task schedulers.

## What It Does
- Automatically detects recently completed Jira sprints (configurable lookback window) and generates professional HTML email reports
- Categorizes sprint issues as **Completed** or **Carried Over**, calculates team contribution metrics, and detects mid-sprint scope changes
- Generates rich emails with sprint metrics dashboard, detailed issue lists, team contribution tables, and scope change analysis
- Prevents duplicate emails by tracking processed sprints with Jira labels
- Designed for scheduled execution (cron, Task Scheduler) with one-time run-and-exit behavior

## Prerequisites
Before running this integration, you need:

### Jira Setup
- A Jira account with API access
- API credentials:
  - **Email** - Your Jira account email
  - **API Token** - Generate from [Atlassian Account Security](https://id.atlassian.com/manage-profile/security/api-tokens)
  - **Base URL** - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
  - **Project Key** - The project key to monitor (e.g., `PROJ`, `DEV`)

This integration uses Basic Authentication with API tokens. Learn how to [create Jira API tokens](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

### Gmail Setup
- A Google account with Gmail access
- OAuth2 credentials:
  - **Client ID**
  - **Client Secret**
  - **Refresh Token**
- **Scopes Required:**
  - `https://www.googleapis.com/auth/gmail.send`
  - `https://www.googleapis.com/auth/gmail.compose`

This integration uses refresh token flow for authentication. Learn how to [Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration
The following configurations are used by the application.

### Jira Credentials
- `jiraEmail` - Your Jira account email address
- `jiraApiToken` - Your Jira API token
- `jiraBaseUrl` - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
- `jiraProjectKey` - The project key to monitor for completed sprints (e.g., `PROJ`)

### Gmail Credentials
- `gmailClientId` - Your Google OAuth2 client ID
- `gmailClientSecret` - Your Google OAuth2 client secret
- `gmailRefreshToken` - Your Google OAuth2 refresh token
- `gmailRecipients` - Array of email addresses to receive sprint summaries (e.g., `["team@example.com", "manager@example.com"]`)

### Lookback Configuration
- `lookbackHours` - How far back to search for completed sprints (fixed: `1460.0` hours / ~61 days)
  - This fixed lookback window ensures all recently completed sprints are captured
  - Combined with Jira label tracking, this prevents duplicate emails across multiple executions

### Scheduling
This is a **scheduled-task integration** that runs once per execution and then exits. It does not poll continuously. Schedule it using:
- **Cron jobs** (Linux/Mac): `0 9 * * * /path/to/bal run` (daily at 9 AM)
- **Windows Task Scheduler**: Create a scheduled task to run on your desired frequency
- **Choreo**: Deploy as a Scheduled Task component and configure execution frequency
- **Kubernetes CronJob**: Deploy as a CronJob resource with your desired schedule

### Email Configuration (Optional)
- `timeZone` - Timezone for email timestamps (default: `America/Los_Angeles`)
- `emailSubjectTemplate` - Email subject template (default: `Sprint Summary: {{sprintName}}`)
  - Available placeholders: `{{sprintName}}`, `{{sprintId}}`

### Summary Sections Toggle 
Customize which sections appear in the email:
- `includeCompletedIssues` - Show completed issues list 
- `includeCarriedOverIssues` - Show carried-over issues list 
- `includeAssigneeBreakdown` - Show team contribution breakdown 
- `includeMidSprintAdditions` - Show issues added mid-sprint 

## Deploying on WSO2 Integration Platform
1. Sign in to your [Devant account](https://console.devant.dev/).
2. Create a new **Scheduled Task** component.
3. Select the **Ballerina** as the buildpack.
4. Choose the component type as **Scheduled Task** and click **Create**.
5. Once the build is successful, click **Configure & Deploy** and set up the required environment variables:
   - All Jira credentials (`jiraEmail`, `jiraApiToken`, `jiraBaseUrl`, `jiraProjectKey`)
   - All Gmail credentials (`gmailClientId`, `gmailClientSecret`, `gmailRefreshToken`, `gmailRecipients`)
   - Optional: Email configuration (`timeZone`, `emailSubjectTemplate`) and section toggles
6. Configure the execution schedule (e.g., daily at 9 AM, every 6 hours, etc.)
7. Click **Deploy** to deploy the integration.
8. The integration will run on your configured schedule, checking for completed sprints and sending summaries.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.