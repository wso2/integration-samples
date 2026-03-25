# Jira Sprint Summary Email Automation

## What It Does

- Monitors a specified Jira board for newly completed sprints using a configurable polling interval.
- Detects sprint completion and queries all sprint issues via JQL.
- Builds a comprehensive sprint summary with issue counts, issue details, and team contribution insights.
- Sends a professionally formatted, responsive HTML email through Gmail with clear visual metrics and timestamps.
- Prevents duplicate notifications by tracking already processed sprint IDs.

<details>
<summary>Jira Setup Guide</summary>
1. A Jira Cloud account with API access
2. Basic Auth credentials:
  - Base URL (your Jira instance URL, e.g., `https://your-domain.atlassian.net`)
  - Email (your Jira account email)
  - API Token (generated from your Jira account)
  - Project Key (the key of the Jira project to query; e.g., "PROJ", "SUPPORT")
This integration uses basic authentication with email and API token. [Learn how to create a Jira API token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).
The project key is usually shown in the URL when you open your project in Jira (e.g., in `https://your-domain.atlassian.net/jira/software/projects/<project_key>/boards/1`, the project key is `<project_key>`). You can also find it on the project sidebar or in the project settings.
</details>

<details>
<summary>Gmail Setup Guide</summary>
1. A Google account with Gmail access
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
3. Scopes Required:
   - `https://www.googleapis.com/auth/gmail.send`
   - `https://www.googleapis.com/auth/gmail.compose`
This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).
</details>

<details>

<summary>Additional Configurations</summary>

1. `timeZone`
   Timezone for email timestamps (e.g., `America/Los_Angeles`, `Europe/London`). Default: `America/Los_Angeles`.

2. `emailSubjectTemplate`
   Email subject template with placeholders. Available placeholders: `{{sprintName}}`, `{{sprintId}}`. Default: `Sprint Summary: {{sprintName}}`.

3. `gmailRecipients`
   Array of email addresses to receive sprint summaries.

4. **Summary Sections Toggle** - Customize which sections appear in the email:
   1. `includeCompletedIssues`: Show completed issues list 
   2. `includeCarriedOverIssues`: Show carried-over issues 
   3. `includeAssigneeBreakdown`: Show team contribution 
   4. `includeMidSprintAdditions`: Show issues added mid-sprint

</details>
