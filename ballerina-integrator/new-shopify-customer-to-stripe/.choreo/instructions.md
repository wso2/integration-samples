## What it does

- When a customer is created in Shopify, the integration creates a customer in Stripe with the customer details.

<details>

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `apiSecretKey` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Customer creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.
</details>

<details>

<summary>Stripe Setup Guide</summary>

1. Log in to your Stripe account and navigate to the **Developers** section.
2. Click on **API keys** in the left sidebar.
3. Copy the value of the **Secret key**. This should be the `secretKey` configuration.

</details>