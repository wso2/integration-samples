# Jira Sprint Summary Email Automation

## What It Does

- Monitors a specified Jira board for newly completed sprints using a configurable polling interval.
- Detects sprint completion and queries all sprint issues via JQL.
- Builds a comprehensive sprint summary with issue counts, issue details, and team contribution insights.
- Sends a professionally formatted, responsive HTML email through Gmail with clear visual metrics and timestamps.
- Prevents duplicate notifications by tracking already processed sprint IDs.

<details>

<summary>Jira Setup Guide</summary>

1. A Jira account with API access
2. API credentials:
   1. Email (Your Jira account email)
   2. API Token (Generate from [Atlassian Account Security](https://id.atlassian.com/manage-profile/security/api-tokens))
   3. Base URL (Your Jira instance URL, e.g., `https://yourcompany.atlassian.net`)
   4. Project Key (e.g., `PROJ`, `DEV`)

This integration uses Basic Authentication with API tokens. [Learn how to create Jira API tokens](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

</details>

<details>

<summary>Gmail Setup Guide</summary>

1. A Google account with Gmail access
2. OAuth2 credentials:
   1. Client ID
   2. Client Secret
   3. Refresh Token
3. Scopes Required:
   1. `https://www.googleapis.com/auth/gmail.send`
   2. `https://www.googleapis.com/auth/gmail.compose`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

</details>

<details>

<summary>Additional Configurations</summary>

1. `pollingIntervalHours`
   How often to check for completed sprints (in hours). Use `0.0833` for approximately 5 minutes.

2. `timeZone`
   Timezone for email timestamps (e.g., `America/Los_Angeles`, `Europe/London`). Default: `America/Los_Angeles`.

3. `emailSubjectTemplate`
   Email subject template with placeholders. Available placeholders: `{{sprintName}}`, `{{sprintId}}`. Default: `Sprint Summary: {{sprintName}}`.

4. `gmailRecipients`
   Array of email addresses to receive sprint summaries.

5. **Summary Sections Toggle** - Customize which sections appear in the email:
   1. `includeCompletedIssues`: Show completed issues list 
   2. `includeCarriedOverIssues`: Show carried over issues 
   3. `includeAssigneeBreakdown`: Show team contribution 
   4. `includeMidSprintAdditions`: Show issues added mid-sprint

</details>
