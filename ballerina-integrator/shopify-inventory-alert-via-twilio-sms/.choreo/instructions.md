## What It Does

- Polls your Shopify store at a configurable interval to check inventory levels across products
- Filters monitoring to specific product IDs or watches all products in the store
- Sends an SMS alert via Twilio to one or more recipient numbers when a product's inventory drops below the configured threshold
- Suppresses repeat alerts for the same SKU until a configurable cooldown period expires
- Supports a customisable SMS message template with product and inventory placeholders

<details>

<summary>Shopify Setup Guide</summary>

1. **Find your store URL** — log in to Shopify Admin and look at the address bar:
    - Your store URL follows the pattern `https://<your-store-name>.myshopify.com`
    - Set this as `shopifyStoreUrl`
2. **Create a Shopify App and get an access token**
    - In Shopify Admin, go to **Settings → Apps and sales channels → Develop apps**
    - Click **Create an app** and give it a name (e.g., `Inventory Monitor`)
    - Under the **Configuration** tab, click **Configure Admin API scopes** and enable:
        - `read_products`
        - `read_inventory`
        - `read_locations`
    - Go to the **API credentials** tab and click **Install app**
    - Copy the **Admin API access token** — this is your `shopifyAccessToken`
    - > **Note:** The token is shown only once. Store it securely.
3. **Find product IDs to monitor** — open a product in Shopify Admin; the numeric ID is at the end of the URL:
    - `https://admin.shopify.com/store/<your-store>/products/<productId>`
    - Set these IDs in `productIdsToMonitor`. Leave the array empty (`[]`) to monitor all products.

</details>

<details>

<summary>Twilio Setup Guide</summary>

1. **Get your Twilio credentials** — log in at [console.twilio.com](https://console.twilio.com)
    - Copy the **Account SID** → `twilioAccountSid`
    - Click to reveal and copy the **Auth Token** → `twilioAuthToken`
2. **Get your Twilio phone number**
    - In the Twilio Console, go to **Phone Numbers → Manage → Active Numbers**
    - Copy the SMS-capable number in E.164 format (e.g., `+12025551234`) → `twilioFromNumber`
3. **Enable Geographic Permissions** (if sending to international numbers)
    - Go to **Messaging → Settings → Geo Permissions**
    - Enable the country of each recipient number
    - > **Trial accounts:** Recipient numbers must be verified under **Phone Numbers → Verified Caller IDs** before SMS can be sent to them.

</details>

<details>

<summary>Additional Configurations</summary>

1. `pollingIntervalSeconds`
    - How often (in seconds) the integration checks Shopify inventory (default: `300`)
2. `inventoryThreshold`
    - An alert is sent when a product's inventory falls below this number (default: `10`)
3. `productIdsToMonitor`
    - Array of Shopify product IDs to watch. Leave empty (`[]`) to monitor all products.
4. `twilioRecipientNumbers`
    - Array of recipient phone numbers in E.164 format (e.g., `["+94711234567"]`)
5. `cooldownPeriodHours`
    - Minimum hours between repeat alerts for the same SKU (default: `24`)
6. `smsTemplate`
    - Customisable SMS message template. Available placeholders:
        - `{{product.id}}` — Shopify product ID
        - `{{product.name}}` — Product name
        - `{{product.inventory}}` — Current inventory count
        - `{{product.sku}}` — Product variant SKU
        - `{{threshold}}` — Configured inventory threshold
    - Default: `INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}`

</details>
