## What It Does

- Receives a real-time webhook from Shopify whenever a new order is created
- Checks the current inventory level of each product variant in the order against a configurable threshold
- Sends an SMS alert via Twilio to one or more recipient numbers when a product's inventory drops below the configured threshold
- Suppresses repeat alerts for the same SKU until a configurable cooldown period expires
- Supports a customisable SMS message template with product and inventory placeholders

<details>

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify Admin. Your store URL follows the pattern `https://<your-store-name>.myshopify.com`. Set this as `storeUrl`.
2. Go to **Settings** > **Apps and sales channels** > **Develop apps** and create an app with `read_products` and `read_inventory` API scopes. Install the app and copy the **Admin API access token** — this is your `accessToken`.
3. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
4. Click on the **Webhooks** section.
5. Copy the key shown under _"Your webhooks will be signed with ..."_. This should be the `apiSecretKey` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Order creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL.
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.

</details>

<details>

<summary>Twilio Setup Guide</summary>

1. Create a Twilio account and obtain a phone number
2. Obtain the Account SID and Auth Token from the Twilio Console
3. (Optional) Enable Geographic Permissions if sending to international numbers

Refer to the [Twilio documentation](https://www.twilio.com/docs/messaging/quickstart) for steps for obtaining credentials.

</details>

<details>

<summary>Additional Configurations</summary>

1. `inventoryThreshold`
    - An alert is sent when an ordered product's inventory falls below this number (default: `10`)
2. `recipientNumbers`
    - Array of recipient phone numbers in E.164 format (e.g., `["+94711234567"]`)
3. `cooldownPeriodHours`
    - Minimum hours between repeat alerts for the same SKU (default: `24`)
4. `smsTemplate`
    - Customisable SMS message template. Available placeholders:
        - `{{product.id}}` — Shopify product ID
        - `{{product.name}}` — Product name
        - `{{product.inventory}}` — Current inventory count
        - `{{product.sku}}` — Product variant SKU
        - `{{threshold}}` — Configured inventory threshold
    - Default: `INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}`

</details>
