# GitHub Issue to Google Chat Integration

## Description

This integration listens to GitHub Webhook events for issues with specific labels added in a specified repository and sends notifications to a Google Chat space with details of the issue.

### What It Does

- Listens for issues with specific labels added in a specified GitHub repository via Webhooks
- Notifies a Google Chat space with the issue details including title, author, labels, and a link to the issue

## Prerequisites

Before running this integration, you need:

### GitHub Setup

1. A GitHub account with repository access
2. A GitHub repository where you want to listen for issue events
3. A GitHub Webhook configured to send issue label update events to this integration
4. You will need to generate a webhook secret to secure the webhook communication

[Learn how to create a Github Webhook](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks).

### Google Chat Setup

1. Navigate to a Google Chat space where you want to send messages
2. Click on the space name > Apps & Integrations > Manage Webhooks
3. Please note that only Google Workspace accounts can create webhooks
4. Click on "Add Webhook" and provide a name and optional avatar URL
5. In the given webhook URL, extract the following:
    - `spaceId`: The value after `/spaces/` and before `/messages`
    - `key`: The value of the `key` query parameter
    - `token`: The value of the `token` query parameter 
    - `https://chat.googleapis.com/v1/spaces/<spaceId>/messages?key=<key>&token=<token>`

## Configuration

The following configurations are required to connect GitHub and Google Chat.

### GitHub Configurations

- `webhookSecret`: The secret key used to secure the GitHub webhook
- `triggerLabels`: An array of labels that will trigger the notification when added to an issue

### Google Chat Credentials

- `spaceId`: The ID of the Google Chat space
- `key`: The key extracted from the Google Chat webhook URL
- `token`: The token extracted from the Google Chat webhook URL

## Deploying on **WSO2 Cloud**

1. Sign in to your WSO2 Cloud account.
2. Create a new Integration and follow instructions in [WSO2 Cloud Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Google Sheets credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, select **Week** from the dropdown.
8. Set the desired day and time for the integration to run weekly and click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.