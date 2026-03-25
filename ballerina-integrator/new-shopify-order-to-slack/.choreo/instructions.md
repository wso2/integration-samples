## What it does

- When a new order is created in Shopify, the integration catches the webhook event and posts a formatted message with the order details to a specified Slack channel.

<details>

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `shopifyApiSecretKey` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Order creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.

</details>

<details>

<summary>Slack Setup Guide</summary>

1. Log in to your Slack workspace and go to the [Slack API Developer Portal](https://api.slack.com/apps).
2. Click **Create New App** and choose **From scratch**.
3. Navigate to **OAuth & Permissions** in the left sidebar.
4. Scroll down to the **Bot Token Scopes** section, click **Add an OAuth Scope**, and select `chat:write`.
5. Scroll up, click **Install to Workspace** (authorize it if prompted), and copy the **Bot User OAuth Token** (starts with `xoxb-`). This should be the `slackToken` configuration.
6. Open your Slack application and ensure the Slack app (bot) is a member of your target channel.
7. Click the channel name at the top to open the details menu, scroll to the bottom of the **About** tab, and copy the **Channel ID** (usually starts with `C` or `G`). This should be the `slackChannelId` configuration.

</details>

<details> 

<summary>Additional Configurations</summary>

1. `customMessage`: 
    - The text template to use for the Slack notification. 
    - Use `<br>` to indicate line breaks.
    - You can use the following placeholders to inject live data from the webhook:
        - `{orderId}`: The Shopify order number
        - `{customerName}`: Full name of the customer
        - `{customerEmail}`: Customer's email address
        - `{itemCount}`: Total number of items purchased
        - `{items}`: List of the items in the order
        - `{subtotal}`: Order cost before taxes/shipping
        - `{taxes}`: Total tax amount
        - `{shipping}`: Total shipping cost
        - `{totalPrice}`: Final total paid
        - `{shippingAddress}`: Destination address
        - `{financialStatus}`: Payment status (e.g., paid, pending)
        - `{fulfillmentStatus}`: Shipping status (e.g., unfulfilled)
        - `{createdAt}`: Timestamp of the order
        - `{currency}`: The currency code (e.g., USD)

2. `minimumOrderPrice`:
    - The minimum order price threshold.
    - Only send Slack notifications for orders above this amount (default: `0` to send all).

</details>