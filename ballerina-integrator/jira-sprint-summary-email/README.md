# Jira Sprint Summary Email Integration

## Description
This integration checks a Jira project for recently completed sprints and automatically sends detailed email summaries to your team via Gmail. When executed, it searches for sprints completed within a configurable lookback window, generates comprehensive HTML reports with metrics and issue breakdowns, and emails them to configured recipients. The integration uses Jira labels to track processed sprints and prevent duplicate notifications. Designed to be run on a schedule via cron jobs or task schedulers.

## What It Does
- Searches for sprints completed within a configurable lookback window (e.g., last 24 hours)
- Queries closed sprints using time-based JQL: `project = <key> AND sprint in closedSprints() AND updated >= "<cutoff_date>"`
- Tracks processed sprints using Jira labels to prevent duplicate emails
- For each newly completed sprint:
  - Fetches all sprint issues with status, assignee, and changelog data
  - Categorizes issues as **Completed** (status category = "done") or **Carried Over** (all others)
  - Calculates team contribution statistics by assignee
  - Detects mid-sprint additions using changelog analysis
  - Generates a professional HTML email with:
    - Sprint metrics dashboard (total, completed, carried over counts)
    - Detailed issue lists with keys, summaries, statuses, and assignees
    - Team contributions table with completion rates and progress bars
    - Mid-sprint additions section highlighting scope changes
- Sends the email to multiple recipients via Gmail
- Marks processed sprints with a label to prevent duplicate processing
- Exits after processing all sprints (suitable for scheduled execution)

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
- `lookbackHours` - How far back to search for completed sprints (default: `24.0`)
  - **Recommended:** Match your execution schedule (e.g., `24.0` for daily runs, `2.0` for every 2 hours)
  - Examples: `2.0` (last 2 hours), `6.0` (last 6 hours), `24.0` (last 24 hours)
  - Set this to slightly more than your execution frequency to avoid missing sprints
  - The integration uses Jira labels to prevent duplicate emails even if sprints appear in multiple runs

### Scheduling
This integration is designed to run once per execution and exit. Schedule it using:
- **Cron jobs** (Linux/Mac): `0 */6 * * * /path/to/bal run` (every 6 hours)
- **Task Scheduler** (Windows): Create a scheduled task
- **Choreo Scheduled Tasks**: Configure execution frequency in Choreo
- **Kubernetes CronJob**: Deploy as a CronJob resource

**Important:** Set `lookbackHours` to slightly more than your execution frequency to ensure no sprints are missed.

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

## Deploying on Choreo
1. Sign in to your [Choreo account](https://console.choreo.dev/).
2. Create a new **Scheduled Task** component and follow instructions in [Choreo Documentation](https://wso2.com/choreo/docs/) to import this repository.
3. Select the **Ballerina** as the buildpack.
4. Choose the component type as **Scheduled Task** and click **Create**.
5. Once the build is successful, click **Configure & Deploy** and set up the required environment variables:
   - All Jira credentials (`jiraEmail`, `jiraApiToken`, `jiraBaseUrl`, `jiraProjectKey`)
   - All Gmail credentials (`gmailClientId`, `gmailClientSecret`, `gmailRefreshToken`, `gmailRecipients`)
   - Lookback configuration (`lookbackHours` - e.g., `24.0` for daily execution)
   - Optional: Email configuration and section toggles
6. Configure the execution schedule (e.g., daily at 9 AM, every 6 hours, etc.)
7. Click **Deploy** to deploy the integration.
8. The integration will run on your configured schedule, checking for completed sprints and sending summaries.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
