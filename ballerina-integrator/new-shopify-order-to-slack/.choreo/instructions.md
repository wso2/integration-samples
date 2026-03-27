## What it does

- When a new order is created in Shopify, the integration catches the webhook event and posts a formatted message with the order details to a specified Slack channel.

<details>
<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `apiSecretKey` configuration.

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

1. A Slack app with a Bot Token
2. The bot must be invited to all channels it will post to
3. Scopes Required:
    - `chat:write`
    - `channels:read` (optional, for channel resolution)
    - `users:read.email` (optional, for tagging lead owners by email)
4. The channel ID or name of the target Slack channel

[Learn how to create a Slack app](https://api.slack.com/start/quickstart).

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