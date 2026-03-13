# Jira Sprint Summary Email Automation

![Ballerina](https://img.shields.io/badge/Ballerina-2201.8.0+-blue) ![License](https://img.shields.io/badge/License-Apache%202.0-green)

## Overview

Automatically monitor your Jira board for completed sprints and send detailed email summaries to your team via Gmail. Get instant notifications with comprehensive sprint metrics, issue breakdowns, and team contributions whenever a sprint completes.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Jira Sprint Summary Email                     │
│                         Integration                              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │ Polls every 5 min (configurable)
                                ▼
                    ┌───────────────────────┐
                    │   Jira Cloud API      │
                    │  (REST API v3)        │
                    └───────────────────────┘
                                │
                                │ JQL Query: closedSprints()
                                ▼
                    ┌───────────────────────┐
                    │  Sprint Detection     │
                    │  - Extract sprint info│
                    │  - Check completion   │
                    │  - Deduplicate        │
                    └───────────────────────┘
                                │
                                │ Recently completed sprint found
                                ▼
                    ┌───────────────────────┐
                    │  Data Collection      │
                    │  - Fetch all issues   │
                    │  - Get changelog      │
                    │  - Extract details    │
                    └───────────────────────┘
                                │
                                │ Process sprint data
                                ▼
                    ┌───────────────────────┐
                    │  Summary Generation   │
                    │  - Completed issues   │
                    │  - Carried over       │
                    │  - Team breakdown     │
                    │  - Mid-sprint adds    │
                    └───────────────────────┘
                                │
                                │ Format HTML email
                                ▼
                    ┌───────────────────────┐
                    │   Gmail API           │
                    │  (OAuth2)             │
                    └───────────────────────┘
                                │
                                │ Send to recipients
                                ▼
                    ┌───────────────────────┐
                    │   Team Inboxes        │
                    │  📧 📧 📧             │
                    └───────────────────────┘
```

## Features

### 🔍 **Automatic Sprint Detection**
- Continuously monitors your Jira project for completed sprints
- Configurable polling interval (default: 5 minutes)
- Smart deduplication prevents duplicate emails

### 📊 **Comprehensive Sprint Metrics**
- **Total Issues**: Complete count of sprint scope
- **Completed Issues**: Issues marked as "Done"
- **Carried Over Issues**: Incomplete work moving to next sprint
- **Team Contributions**: Per-assignee breakdown with completion rates
- **Mid-Sprint Additions**: Tracks scope changes during the sprint

### 📧 **Professional Email Reports**
- Beautiful HTML email with Jira-themed design
- Responsive layout for desktop and mobile
- Color-coded metrics and visual progress bars
- Detailed issue lists with keys, summaries, and assignees
- Support for multiple recipients

### ⚙️ **Highly Configurable**
- Toggle individual report sections on/off
- Customize email subject with placeholders
- Configure timezone for timestamps
- Adjust polling frequency



## Prerequisites
Before running this integration, you need:

### Jira Setup
- A Jira account with API access
- API credentials:
  - **Email** - Your Jira account email
  - **API Token** - Generate from [Atlassian Account Security](https://id.atlassian.com/manage-profile/security/api-tokens)
  - **Base URL** - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
  - **Project Key** - The project key (e.g., `PROJ`, `DEV`)

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

This integration uses refresh token flow for auth. Learn how to [Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration
The following configurations are required to connect to Jira and Gmail.

### Jira Credentials
- `jiraEmail` - Your Jira account email address
- `jiraApiToken` - Your Jira API token
- `jiraBaseUrl` - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
- `jiraProjectKey` - The project key to monitor for completed sprints (e.g., `PROJ`)

### Gmail Credentials
- `gmailClientId` - Your Google OAuth2 client ID
- `gmailClientSecret` - Your Google OAuth2 client secret
- `gmailRefreshToken` - Your Google OAuth2 refresh token
- `gmailRecipients` - Array of email addresses to receive sprint summaries

### Polling Configuration
- `pollingIntervalSeconds` - How often to check for completed sprints (default: `300` seconds / 5 minutes)

### Email Configuration
- `timeZone` - Timezone for email timestamps (default: `America/Los_Angeles`)
- `emailSubjectTemplate` - Email subject template (default: `Sprint Summary: {{sprintName}}`)
  - Available placeholders: `{{sprintName}}`, `{{sprintId}}`

### Summary Sections Toggle
Customize which sections appear in the email:
- `includeCompletedIssues` - Show completed issues list (default: `true`)
- `includeCarriedOverIssues` - Show carried over issues list (default: `true`)
- `includeAssigneeBreakdown` - Show team contribution breakdown (default: `true`)
- `includeMidSprintAdditions` - Show issues added to the sprint after it started (default: `true`)

## Running Locally

### Prerequisites
- [Ballerina](https://ballerina.io/downloads/) 2201.8.0 or later installed

### Steps
1. Clone this repository
2. Create a `Config.toml` file in the project root with your credentials:

```toml
# Jira Configuration
jiraEmail = "your-email@example.com"
jiraApiToken = "your-jira-api-token"
jiraBaseUrl = "https://yourcompany.atlassian.net"
jiraProjectKey = "PROJ"
jiraBoardId = 123

# Gmail Configuration
gmailClientId = "your-google-client-id"
gmailClientSecret = "your-google-client-secret"
gmailRefreshToken = "your-google-refresh-token"
gmailRecipients = ["team@example.com", "manager@example.com"]

# Polling Configuration
pollingIntervalSeconds = 300

# Email Configuration
timeZone = "America/Los_Angeles"
emailSubjectTemplate = "Sprint Summary: {{sprintName}}"

# Summary Sections Toggle
includeCompletedIssues = true
includeCarriedOverIssues = true
includeAssigneeBreakdown = true
includeMidSprintAdditions = true
```

3. Run the integration:
```bash
bal run
```

The integration will:
- Test the Jira connection
- List available projects to help you verify configuration
- Start monitoring for completed sprints
- Send email summaries when sprints are completed

## Deploying on Choreo

1. Sign in to your [Choreo account](https://console.choreo.dev/)
2. Create a new **Manual Task** component
3. Connect your GitHub repository containing this code
4. Configure the following environment variables in Choreo:
   - All Jira credentials
   - All Gmail credentials
   - Polling and email configuration
   - Summary section toggles
5. Deploy the component
6. The integration will run continuously, monitoring for completed sprints

## How It Works

1. **Connection Testing**: On startup, the integration verifies Jira credentials and lists available projects
2. **Continuous Monitoring**: The system polls Jira at the configured interval (default: every 5 minutes)
3. **Sprint Detection**: Uses JQL queries to find issues in closed sprints
4. **Deduplication**: Tracks processed sprints to prevent duplicate emails
5. **Summary Generation**: For each newly completed sprint:
   - Fetches all sprint issues with details
   - Categorizes issues as completed or incomplete based on status
   - Calculates team contribution statistics
   - Generates formatted HTML email
6. **Email Delivery**: Sends professional HTML email via Gmail with all sprint metrics

## Email Features

The generated email includes:
- **Header**: Sprint name, ID, completion date, and timestamp
- **Metrics Dashboard**: Total, completed, and carried over issue counts
- **Issue Lists**: Detailed breakdowns with issue keys, summaries, statuses, and assignees
- **Team Contributions**: Table showing each team member's completed/carried over/total issues with visual progress bars
- **Mid-Sprint Additions**: Highlights issues added to the sprint after it started, detected via changelog analysis (when enabled)
- **Responsive Design**: Optimized for both desktop and mobile viewing
- **Professional Styling**: Jira-themed colors and branding

## Troubleshooting

### Jira Connection Issues
- Verify your `jiraEmail` matches your Atlassian account email
- Ensure your API token is valid and not expired
- Check that `jiraBaseUrl` is correct (should not include `/rest`)
- Confirm you have access to the specified board and project

### Gmail Issues
- Verify OAuth2 credentials are valid
- Ensure refresh token has not expired
- Check that required Gmail API scopes are enabled

### No Emails Received
- Check that sprints are actually completing within the monitoring period
- Verify `pollingIntervalSeconds` is appropriate for your sprint cadence
- Review logs for any error messages
- Ensure `gmailRecipients` email addresses are correct

## License
This project is available under the Apache License 2.0.
