# Jira Sprint Summary Email Integration

## Description
This integration monitors a Jira project for completed sprints and automatically sends detailed email summaries to your team via Gmail. Each time a sprint is completed, the integration detects it, generates a comprehensive HTML report with metrics and issue breakdowns, and emails it to configured recipients. The integration maintains state to prevent duplicate notifications and continues running to catch all future sprint completions.

## What It Does
- Polls Jira continuously at a configurable interval (in hours) to detect completed sprints
- Queries closed sprints using JQL: `project = <key> AND sprint in closedSprints()`
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
- Persists processed sprint IDs to `processed_sprints.json` to prevent duplicate emails
- Continues polling for future sprint completions with error isolation per sprint

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

### Polling Configuration
- `pollingIntervalHours` - How often to check for completed sprints in hours (`0.5` for 30 minutes, `1.0` for 1 hour)

### Email Configuration (Optional)
- `timeZone` - Timezone for email timestamps (default: `America/Los_Angeles`)
- `emailSubjectTemplate` - Email subject template (default: `Sprint Summary: {{sprintName}}`)
  - Available placeholders: `{{sprintName}}`, `{{sprintId}}`

### Summary Sections Toggle (Optional)
Customize which sections appear in the email:
- `includeCompletedIssues` - Show completed issues list 
- `includeCarriedOverIssues` - Show carried-over issues list 
- `includeAssigneeBreakdown` - Show team contribution breakdown 
- `includeMidSprintAdditions` - Show issues added mid-sprint 

## Deploying on Choreo
1. Sign in to your [Choreo account](https://console.choreo.dev/).
2. Create a new **Manual Task** component and follow instructions in [Choreo Documentation](https://wso2.com/choreo/docs/) to import this repository.
3. Select the **Ballerina** as the buildpack.
4. Choose the component type as **Manual Task** and click **Create**.
5. Once the build is successful, click **Configure & Deploy** and set up the required environment variables:
   - All Jira credentials (`jiraEmail`, `jiraApiToken`, `jiraBaseUrl`, `jiraProjectKey`)
   - All Gmail credentials (`gmailClientId`, `gmailClientSecret`, `gmailRefreshToken`, `gmailRecipients`)
   - Polling configuration (`pollingIntervalHours`)
   - Optional: Email configuration and section toggles
6. Click **Deploy** to deploy the integration.
7. The integration will start running continuously, monitoring for completed sprints at the configured interval.
8. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
