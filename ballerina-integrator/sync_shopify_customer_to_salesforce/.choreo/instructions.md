## What It Does

- Listens for Shopify webhook events triggered when a new customer is created.
- Checks whether the customer already exists in Salesforce as a contact, preventing duplicate records.
- Automatically creates a new Salesforce contact when a new customer signs up on Shopify.

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `shopifySecret` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Customer creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.
</details>

</details>

