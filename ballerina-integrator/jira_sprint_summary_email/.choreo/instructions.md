# Jira Sprint Summary Email Automation

## What It Does

- Continuously monitors a specified Jira board for newly completed sprints
- Detects sprint completion events in real-time using configurable polling intervals
- Queries all issues from completed sprints using JQL
- Generates comprehensive sprint summaries including:
  - Total, completed, and incomplete issue counts
  - Detailed lists of completed and incomplete issues with assignee information
  - Team contribution breakdown with completion rates
- Sends beautifully formatted HTML emails via Gmail with:
  - Professional Jira-themed design
  - Responsive layout for mobile and desktop
  - Color-coded metrics and progress bars
  - Timestamped sprint completion information
- Prevents duplicate emails by tracking processed sprints

<details>

<summary>Jira Setup Guide</summary>

1. A Jira account with API access
2. API credentials:
   - Email (Your Jira account email)
   - API Token (Generate from [Atlassian Account Security](https://id.atlassian.com/manage-profile/security/api-tokens))
   - Base URL (Your Jira instance URL, e.g., `https://yourcompany.atlassian.net`)
   - Project Key (e.g., `PROJ`, `DEV`)

This integration uses Basic Authentication with API tokens. [Learn how to create Jira API tokens](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

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

1. `pollingIntervalSeconds`
   - How often to check for completed sprints (in seconds)
   - Default: `300` (5 minutes)

2. `timeZone`
   - Timezone for email timestamps (e.g., `America/Los_Angeles`, `Europe/London`)
   - Default: `America/Los_Angeles`

3. `emailSubjectTemplate`
   - Email subject template with placeholders
   - Available placeholders: `{{sprintName}}`, `{{sprintId}}`
   - Default: `Sprint Summary: {{sprintName}}`

4. `gmailRecipient`
   - Email address to receive sprint summaries

5. **Summary Sections Toggle** - Customize which sections appear in the email:
   - `includeCompletedIssues`: Show completed issues list (default: `true`)
   - `includeIncompleteIssues`: Show incomplete issues list (default: `true`)
   - `includeAssigneeBreakdown`: Show team contribution breakdown (default: `true`)
   - `includeMidSprintAdditions`: Show issues added mid-sprint (default: `false`, future feature)
   - `includeVelocity`: Show velocity statistics (default: `false`, future feature)

</details>
