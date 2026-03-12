# Shopify Inventory Alert via Twilio SMS — Setup Instructions

Follow the steps below to configure this integration. You will need credentials from **Shopify** and **Twilio** before deploying.

---

## Step 1: Set Up Shopify Access

### 1.1 Find Your Store URL

Log in to your Shopify Admin and look at the address bar:

```
https://admin.shopify.com/store/<your-store-name>/...
```

Your store URL is:

```
https://<your-store-name>.myshopify.com
```

Set this as `shopifyStoreUrl`.

### 1.2 Create a Shopify App and Get an Access Token

1. In Shopify Admin, go to **Settings → Apps and sales channels → Develop apps**.
2. Click **Create an app** and give it a name (e.g., `Inventory Monitor`).
3. Under the **Configuration** tab, click **Configure Admin API scopes** and enable:
   - `read_products`
   - `read_inventory`
   - `read_locations`
4. Click **Save**.
5. Go to the **API credentials** tab and click **Install app**.
6. Copy the **Admin API access token** — this is your `shopifyAccessToken`.

> **Note:** The token is shown only once. Store it securely.

### 1.3 Find Product IDs to Monitor

To monitor specific products, you need their Shopify product IDs. Open a product in Shopify Admin — the numeric ID is at the end of the URL:

```
https://admin.shopify.com/store/<your-store>/products/8194105999407
```

Set these IDs in `productIdsToMonitor`. Leave the array empty (`[]`) to monitor all products.

---

## Step 2: Set Up Twilio

### 2.1 Get Your Twilio Credentials

1. Log in at [console.twilio.com](https://console.twilio.com).
2. On the dashboard, copy:
   - **Account SID** → `twilioAccountSid`
   - **Auth Token** (click to reveal) → `twilioAuthToken`

### 2.2 Get Your Twilio Phone Number

1. In the Twilio Console, go to **Phone Numbers → Manage → Active Numbers**.
2. Copy the SMS-capable number in E.164 format (e.g., `+12025551234`) → `twilioFromNumber`.

### 2.3 Enable Geographic Permissions

If sending to international numbers:

1. Go to **Messaging → Settings → Geo Permissions**.
2. Enable the country of each recipient number.

> **Trial accounts:** Recipient numbers must be verified under **Phone Numbers → Verified Caller IDs** before SMS can be sent to them.

---

## Step 3: Configure the Integration

Set the following environment variables when deploying on Devant:

### Shopify

| Variable | Description | Example |
|----------|-------------|---------|
| `shopifyStoreUrl` | Your store URL | `https://my-store.myshopify.com` |
| `shopifyAccessToken` | Admin API access token | `shpat_xxxxxxxxxxxx` |

### Twilio

| Variable | Description | Example |
|----------|-------------|---------|
| `twilioAccountSid` | Twilio Account SID | `ACxxxxxxxxxxxxxxxx` |
| `twilioAuthToken` | Twilio Auth Token | `xxxxxxxxxxxxxxxx` |
| `twilioFromNumber` | Sender phone number (E.164) | `+12025551234` |
| `twilioRecipientNumbers` | Recipient phone numbers (E.164) | `["+94711234567"]` |

### Inventory Monitoring

| Variable | Description | Default |
|----------|-------------|---------|
| `inventoryThreshold` | Alert when inventory falls below this number | `10` |
| `productIdsToMonitor` | Shopify product IDs to watch (empty = all products) | `[]` |
| `pollingIntervalSeconds` | How often to check inventory (seconds) | `300` |
| `cooldownPeriodHours` | Minimum hours between repeat alerts for the same SKU | `24` |

### Notification

| Variable | Description | Default |
|----------|-------------|---------|
| `smsTemplate` | SMS message template with placeholders | See below |

**Available placeholders for `smsTemplate`:**

- `{{product.id}}` — Shopify product ID
- `{{product.name}}` — Product name
- `{{product.inventory}}` — Current inventory count
- `{{product.sku}}` — Product variant SKU
- `{{threshold}}` — Configured inventory threshold

**Default template:**
```
INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}
```

---

## Step 4: Deploy

1. Once all environment variables are configured, click **Deploy**.
2. The integration will start polling your Shopify store at the configured interval.
3. An SMS will be sent to all recipient numbers whenever a monitored product's inventory drops below the threshold.
4. Repeat alerts for the same SKU are suppressed until the cooldown period expires.
