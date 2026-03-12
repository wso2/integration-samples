## What it does

- Query Jira issues using a JQL query.
- Fetches issue details and builds a short HTML summary (shows up to `maxIssuesToDisplay` issues).
- Sends the summary email via Mailchimp Transactional (Mandrill).

<details>

<summary>Jira Cloud Setup Guide</summary>

This integration uses **Jira Cloud REST APIs** with **Basic Auth** where:

- `jiraConfig.username` = your Atlassian account **email**
- `jiraConfig.password` = your Atlassian **API token** (not your account password)

1. Find your Jira Cloud site domain.
   - If your Jira URL is `https://<domain>.atlassian.net`, your `jiraConfig.domain` is `<domain>`.
2. Create an Atlassian API token.
   - [Atlassian API tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
3. Pick a JQL query to select the issues you want summarized (example: `project = ABC AND statusCategory != Done`).

Reference:

- [Basic auth for REST APIs (Jira Cloud)](https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/)

</details>

<details>

<summary>Mailchimp Transactional (Mandrill) Setup Guide</summary>

This integration uses **Mailchimp Transactional** to send emails via the `messages/send` API.

1. Ensure you have access to Mailchimp Transactional (Mandrill).
2. Generate a Transactional API key and use it as `mailchimpConfig.mandrillApiKey`.
3. Configure a sender:
   - `mailchimpConfig.fromEmail`: the From email address you want recipients to see
   - `mailchimpConfig.fromName`: the From name you want recipients to see
4. Set recipients:
   - `mailchimpConfig.recipients`: a list of email addresses to receive the summary

Reference:

- [Mailchimp Transactional developer docs](https://mailchimp.com/developer/transactional/)
- [Messages API reference](https://mailchimp.com/developer/transactional/api/messages/)

</details>

## Configuration

### `jiraConfig`

- `username`: Atlassian account email
- `password`: Atlassian API token
- `domain`: Jira Cloud domain (the `<domain>` part of `https://<domain>.atlassian.net`)
- `jqlQuery`: JQL query used to pick issues for the summary

### `mailchimpConfig`

- `mandrillApiKey`: Mailchimp Transactional API key
- `fromEmail`: sender email address
- `fromName`: sender display name
- `recipients`: list of recipient email addresses

### `maxIssuesToDisplay`

- Maximum number of Jira issues to include in the email summary (default: `5`).

