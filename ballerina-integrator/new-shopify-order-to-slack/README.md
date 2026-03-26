# Send a message to a Slack channel when a Shopify order is made

## Description

This integration listens for new order creation events in Shopify and sends a customized notification to a specified Slack channel.

### What it does

- When a new order is created in Shopify, the integration catches the webhook event, extracts the order details, and posts a formatted message to a Slack channel to notify the team.

## Prerequisites

Before running this integration, you need:

### Shopify Setup

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'.
4. Create a webhook for the **Order creation** event with the format set to **JSON** and the URL set to the deployed integration's endpoint URL.

### Slack Setup

1. Log in to your Slack workspace and go to the [Slack API Developer Portal](https://api.slack.com/apps).
2. Click **Create New App** and choose **From scratch**.
3. Navigate to **OAuth & Permissions** in the left sidebar.
4. Scroll down to the **Bot Token Scopes** section, click **Add an OAuth Scope**, and select `chat:write`.
5. If you plan to post to public channels without adding the bot as a member, also add the `chat:write.public` scope.
6. Scroll up and click **Install to Workspace** (authorize it if prompted).
7. Copy the **Bot User OAuth Token** (it starts with `xoxb-`).
8. Open your Slack application and navigate to the target channel where you want to post notifications.
9. Click the channel name at the top to open the details menu, go to the **Integrations** tab, and click **Add an App** to add your bot to the channel (required for private channels and recommended for public channels if you didn't add `chat:write.public` scope).
10. In the channel details, scroll to the bottom of the **About** tab and copy the **Channel ID** (it usually starts with `C` or `G`).

## Configuration

The following configurations are required for the integration:

### Shopify Configuration
- `shopifyConfig.apiSecretKey`: The API secret key obtained from the Shopify webhooks setup.

### Slack Configuration
- `slackConfig.token`: The Bot User OAuth Token obtained from the Slack app setup.
- `slackConfig.channelId`: The unique ID of the Slack channel where the notification will be sent.

### Optional Configuration
- `customMessage`: (Optional) The text template for the Slack message with placeholders for order details. A default template is provided in `config.bal`. Use `<br>` to indicate line breaks if customizing the message. Available placeholders: `{orderId}`, `{customerName}`, `{customerEmail}`, `{currency}`, `{totalPrice}`, `{itemCount}`, `{items}`, `{shippingAddress}`, `{financialStatus}`, `{fulfillmentStatus}`, `{createdAt}`, `{subtotal}`, `{taxes}`, `{shipping}`.
- `minimumOrderPrice`: (Optional) Minimum order price threshold in decimal format. Only orders with a total price greater than or equal to this value will trigger Slack notifications. Default is `0.0` (all orders are notified).

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration Type** as `Integration as API` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required environment variables.
6. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
