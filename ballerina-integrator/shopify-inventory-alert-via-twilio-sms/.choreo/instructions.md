## What It Does

- Receives a real-time webhook from Shopify whenever a new order is created
- Checks the current inventory level of each product variant in the order against a configurable threshold
- Sends an SMS alert via Twilio to one or more recipient numbers when a product's inventory drops below the configured threshold
- Suppresses repeat alerts for the same SKU until a configurable cooldown period expires
- Supports a customisable SMS message template with product and inventory placeholders

<details>

<summary>Shopify Setup Guide</summary>

1. **Find your store URL** — log in to Shopify Admin and look at the address bar:
    - Your store URL follows the pattern `https://<your-store-name>.myshopify.com`
    - Set this as `storeUrl`
2. **Create a Shopify App and get an access token**
    - In Shopify Admin, go to **Settings → Apps and sales channels → Develop apps**
    - Click **Create an app** and give it a name (e.g., `Inventory Monitor`)
    - Under the **Configuration** tab, click **Configure Admin API scopes** and enable:
        - `read_products`
        - `read_inventory`
    - Go to the **API credentials** tab and click **Install app**
    - Copy the **Admin API access token** — this is your `accessToken`
    - > **Note:** The token is shown only once. Store it securely.
3. **Get the webhook signing secret and register a webhook**
    - In Shopify Admin, go to **Settings → Notifications → Webhooks**
    - Copy the secret shown under _"Your webhooks will be signed with"_ — this is your `apiSecretKey`
    - Click **Create webhook** and configure:
        - **Event**: `Order creation`
        - **Format**: `JSON`
        - **URL**: the public endpoint URL of this deployed integration

</details>

<details>

<summary>Twilio Setup Guide</summary>

1. **Get your Twilio credentials** — log in at [console.twilio.com](https://console.twilio.com)
    - Copy the **Account SID** → `accountSid`
    - Click to reveal and copy the **Auth Token** → `authToken`
2. **Get your Twilio phone number**
    - In the Twilio Console, go to **Phone Numbers → Manage → Active Numbers**
    - Copy the SMS-capable number in E.164 format (e.g., `+12025551234`) → `fromNumber`
3. **Enable Geographic Permissions** (if sending to international numbers)
    - Go to **Messaging → Settings → Geo Permissions**
    - Enable the country of each recipient number
    - > **Trial accounts:** Recipient numbers must be verified under **Phone Numbers → Verified Caller IDs** before SMS can be sent to them.

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
