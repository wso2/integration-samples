## What it does

- Query Jira issues using a JQL query.
- Fetches issue details and builds a short HTML summary (shows up to `maxIssuesToDisplay` issues).
- Sends the summary email via Mailchimp Transactional (Mandrill).

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

<summary>Mailchimp Transactional Setup Guide</summary>

1. A Mailchimp Transactional account
2. API Key from Mailchimp Transactional
   - Log in to Mailchimp Transactional
   - Navigate to **Settings > API Keys**
   - Click **Create New Key** and give it a description
   - Copy the generated API key
     [Learn how to get Mailchimp Transactional API Keys](https://mailchimp.com/developer/transactional/guides/quick-start/#generate-your-api-key).

</details>
