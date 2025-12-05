# API to Create Salesforce Contact and Notify Google Chat on User Signup

## Description

This integration creates a Salesforce Contact for every new user signup received through an HTTP endpoint and sends a notification to a Google Chat space about the new signup.

### What It Does

- When a new user signs up through an HTTP endpoint,
    - Creates a new Contact in Salesforce with the user's details
    - Sends a message to a Google Chat space notifying about the new signup

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID (Consumer Key)
  - Client Secret (Consumer Secret)
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Google Chat Setup

1. Navigate to a Google Chat space where you want to send messages
2. Click on the space name > Apps & Integrations > Manage Webhooks
3. Please note that only Google Workspace accounts can create webhooks
4. Click on "Add Webhook" and provide a name and optional avatar URL
5. In the given webhook URL, extract the following:
    - `spaceId`: The value after `/spaces/` and before `/messages`
    - `key`: The value of the `key` query parameter
    - `token`: The value of the `token` query parameter 
    - The webhook URL follows this structure: `https://chat.googleapis.com/v1/spaces/<spaceId>/messages?key=<key>&token=<token>`

## Configuration

The following configurations are required to connect Salesforce and Google Chat.

### Salesforce Credentials

- `refreshToken` - Your Salesforce OAuth2 refresh token
- `clientId` - Your Salesforce OAuth2 client ID, also known as Consumer Key
- `clientSecret` - Your Salesforce OAuth2 client secret, also known as Consumer Secret
- `refreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://your-instance.salesforce.com/services/oauth2/token`)
- `baseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)

### Google Chat Credentials

- `spaceId`: The ID of the Google Chat space
- `key`: The key extracted from the Google Chat webhook URL
- `token`: The token extracted from the Google Chat webhook URL

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.