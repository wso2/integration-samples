
# Shopify Customer to Salesforce

This integration synchronizes customer data from Shopify to Salesforce, ensuring your customer information stays up-to-date across both platforms.

## Overview

Automatically create customer records created or updated in Shopify to your Salesforce organization.

## Features

- **Real-time Sync**: Automatically push customer updates from Shopify to Salesforce
- **Field Mapping**: Maps Shopify customer attributes to Salesforce Contact/Account fields
- **Error Handling**: Robust error handling and retry logic

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Shopify Setup

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'.
4. Create a webhook for the **Customer creation** event with the format set to **JSON** and the URL set to the deployed integration's endpoint URL.

## Configuration

The following configurations are required for the integration:

### Shopify Configuration
- `apiSecretKey`: The API secret key obtained from the Shopify setup.

### Salesforce Credentials

- `refreshToken` - Your Salesforce OAuth2 refresh token
- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret
- `refreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://your-instance.salesforce.com/services/oauth2/token`)
- `baseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)

## Deploying on **WSO2 Cloud**

1. Sign in to your WSO2 Cloud account.
2. Create a new Integration and follow instructions in [WSO2 Cloud Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Integration as API` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required environment variables.
6. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
