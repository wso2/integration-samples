# Send Jira Issue Summary via Mailchimp Transactional

## Description

This integration runs as a scheduled automation that queries Jira issues using JQL and sends a concise HTML summary email
via Mailchimp Transactional (Mandrill).

### What it does

- Queries Jira Cloud issues using JQL query
- Fetches issue details and generates an HTML summary (shows up to `maxIssuesToDisplay` issues)
- Sends the summary email using Mailchimp Transactional

Try this in Devant:

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/jira-summary-mailchimp)

## Prerequisites

Before running this integration, you need:

### Jira Cloud Setup

This integration uses **Jira Cloud REST APIs** with **Basic Auth** where:

- `jiraConfig.username` = your Atlassian account email
- `jiraConfig.password` = your Atlassian API token (not your account password)

1. Identify your Jira Cloud site domain.
   - If your Jira URL is `https://<domain>.atlassian.net`, your `jiraConfig.domain` is `<domain>`.
2. Create an Atlassian API token.
   - [Atlassian API tokens](https://id.atlassian.com/manage-profile/security/api-tokens)

Reference:

- [Basic auth for REST APIs (Jira Cloud)](https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/)

### Mailchimp Transactional (Mandrill) Setup

1. Ensure you have access to Mailchimp Transactional (Mandrill).
2. Generate a Transactional API key and use it as `mailchimpConfig.mandrillApiKey`.

Reference:

- [Mailchimp Transactional developer docs](https://mailchimp.com/developer/transactional/)
- [Messages API reference](https://mailchimp.com/developer/transactional/api/messages/)

## Configuration

The following configurations are required for the integration:

### Jira Configuration

- `username`: Atlassian account email
- `password`: Atlassian API token
- `domain`: Jira Cloud domain (the `<domain>` part of `https://<domain>.atlassian.net`)
- `jqlQuery`: JQL query used to pick issues for the summary

### Mailchimp Transactional Configuration

- `mandrillApiKey`: Mailchimp Transactional API key
- `fromEmail`: sender email address
- `fromName`: sender display name
- `recipients`: list of recipient email addresses

### Additional Configuration

- `maxIssuesToDisplay`: maximum number of Jira issues to include in the email summary (default: `5`)

```toml
maxIssuesToDisplay = 5

[jiraConfig]
username = "<your_atlassian_email>"
password = "<your_atlassian_api_token>"
domain = "<your_jira_domain>"
jqlQuery = "project = ABC AND statusCategory != Done"

[mailchimpConfig]
mandrillApiKey = "<your_mailchimp_transactional_api_key>"
fromEmail = "no-reply@example.com"
fromName = "Jira Summary Bot"
recipients = ["dev-team@example.com"]
```

## Deploying on WSO2 Integration Platform

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required configuration values.
6. Click **Schedule** and configure when you want the automation to run.
7. Once tested, you may promote the integration to production. Make sure to set the relevant configuration values in the production environment as well.
