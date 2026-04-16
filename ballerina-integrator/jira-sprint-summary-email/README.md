# Jira Sprint Summary Email Integration

## What It Does
- Automatically detects recently completed Jira sprints (configurable lookback window) and generates professional HTML email reports
- Categorizes sprint issues as **Completed** or **Carried Over**, calculates team contribution metrics, and detects mid-sprint scope changes
- Generates rich emails with sprint metrics dashboard, detailed issue lists, team contribution tables, and scope change analysis
- Prevents duplicate emails by tracking processed sprints with Jira labels
- Designed for scheduled execution (cron, Task Scheduler) with one-time run-and-exit behavior

<details>
<summary>Prerequisites</summary>

Before running this integration, you need:

<details>
<summary>Jira Setup</summary>

- A Jira account with API access
- API credentials:
  - **Email** - Your Jira account email
  - **API Token** - Generate from [Atlassian Account Security](https://id.atlassian.com/manage-profile/security/api-tokens)
  - **Base URL** - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
  - **Project Key** - The project key to monitor (e.g., `PROJ`, `DEV`)

This integration uses Basic Authentication with API tokens. Learn how to [create Jira API tokens](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

</details>

<details>
<summary>Gmail Setup</summary>

- A Google account with Gmail access
- OAuth2 credentials:
  - **Client ID**
  - **Client Secret**
  - **Refresh Token**
- **Scopes Required:**
  - `https://www.googleapis.com/auth/gmail.send`
  - `https://www.googleapis.com/auth/gmail.compose`

This integration uses refresh token flow for authentication. Learn how to [Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started/).

</details>

</details>

<details>
<summary>Configuration</summary>

The following configurations are used by the application.

<details>
<summary> Jira Credentials</summary>

Configure in `Config.toml` under `[jira]` section:

```toml
[jira]
email = "your-email@example.com"
apiToken = "your-jira-api-token"
baseUrl = "https://yourcompany.atlassian.net"
projectKey = "PROJ"
```

- `email` - Your Jira account email address
- `apiToken` - Your Jira API token
- `baseUrl` - Your Jira instance URL (e.g., `https://yourcompany.atlassian.net`)
- `projectKey` - The project key to monitor for completed sprints (e.g., `PROJ`)

</details>

<details>
<summary> Gmail Credentials</summary>

Configure in `Config.toml` under `[gmail]` section:

```toml
[gmail]
clientId = "your-google-client-id"
clientSecret = "your-google-client-secret"
refreshToken = "your-google-refresh-token"
recipients = ["team@example.com", "manager@example.com"]
```

- `clientId` - Your Google OAuth2 client ID
- `clientSecret` - Your Google OAuth2 client secret
- `refreshToken` - Your Google OAuth2 refresh token
- `recipients` - Array of email addresses to receive sprint summaries

</details>

<details>
<summary> Email Configuration (Optional)</summary>

Configure in `Config.toml` under `[email]` section:

```toml
[email]
timeZone = "America/Los_Angeles"
subjectTemplate = "Sprint Summary: {{sprintName}}"
```

- `timeZone` - Timezone for email timestamps (default: `America/Los_Angeles`)
- `subjectTemplate` - Email subject template (default: `Sprint Summary: {{sprintName}}`)
  - Available placeholders: `{{sprintName}}`, `{{sprintId}}`

</details>

<details>
<summary> Summary Sections Toggle (Optional)</summary>

Configure in `Config.toml` under `[summary]` section:

```toml
[summary]
includeCompletedIssues = true
includeCarriedOverIssues = true
includeAssigneeBreakdown = true
includeMidSprintAdditions = true
```

Customize which sections appear in the email:

- `includeCompletedIssues` - Show completed issues list
- `includeCarriedOverIssues` - Show carried-over issues list
- `includeAssigneeBreakdown` - Show team contribution breakdown
- `includeMidSprintAdditions` - Show issues added mid-sprint 

</details>

</details>
