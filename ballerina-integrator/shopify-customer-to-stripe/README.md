# Create Shopify Customers in Stripe Integration

## Description

This integration listens for new customer creation events in Shopify and creates corresponding customers in Stripe using the customer details.

### What it does

- When a customer is created in Shopify, the integration creates a customer in Stripe with the customer details.

## Prerequisites

Before running this integration, you need:

### Shopify Setup

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'.
4. Create a webhook for the **Customer creation** event with the format set to **JSON** and the URL set to the deployed integration's endpoint URL.

### Stripe Setup

1. Log in to your Stripe account and navigate to the **Developers** section.
2. Click on **API keys** in the left sidebar.
3. Copy the value of the **Secret key**.

## Configuration

The following configurations are required for the integration:

### Shopify Configuration
- `apiSecretKey`: The API secret key obtained from the Shopify setup.

### Stripe Configuration
- `secretKey`: The secret key obtained from the Stripe setup.

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required environment variables.
6. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.