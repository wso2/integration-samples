# Shopify Inventory Alert via Twilio SMS

## Description

This integration listens for new orders on your Shopify store and automatically sends SMS notifications via Twilio when an ordered product's inventory falls below a defined threshold.

### What It Does

- Receives a real-time webhook from Shopify whenever a new order is created
- Checks the current inventory level of each product variant in the order against a configurable threshold
- Sends SMS alerts to one or more recipient phone numbers when stock is low
- Enforces a per-SKU cooldown period to prevent duplicate alerts within a configured time window
- Supports a fully customizable SMS message template with product-specific placeholders

## Prerequisites

Before running this integration, you need:

### Shopify Setup

- A Shopify store with Admin API access
- A Shopify Admin API access token with the following scopes: `read_products`, `read_inventory`
- Your store's permanent `.myshopify.com` domain
- To create a new app and obtain an access token, follow the [Shopify Admin API getting started guide](https://shopify.dev/docs/api/admin-rest)
- A webhook configured in **Shopify Admin → Settings → Notifications → Webhooks**:
  - Copy the signing secret shown under _"Your webhooks will be signed with"_ — this is your `apiSecretKey`
  - Click **Create webhook**, set **Event** to `Order creation`, **Format** to `JSON`, and set the **URL** to the public endpoint of this deployed integration

### Twilio Setup

- A Twilio account with an active SMS-capable phone number
- The recipient country must be enabled under **Twilio Console → Messaging → Settings → Geo Permissions**
- For trial accounts, recipient numbers must be verified under **Twilio Console → Phone Numbers → Verified Caller IDs**

## Configuration

The following configurations are required to connect to Shopify and Twilio.

### Shopify Credentials

- `storeUrl` - Your store URL (e.g., `https://your-store.myshopify.com`)
- `accessToken` - Admin API access token (`shpat_...`)
- `apiSecretKey` - Webhook signing secret from **Shopify Admin → Settings → Notifications → Webhooks**

### Twilio Credentials

- `accountSid` - Your Twilio Account SID (`AC...`)
- `authToken` - Your Twilio Auth Token
- `fromNumber` - Your Twilio phone number in E.164 format (e.g., `+12025551234`)
- `recipientNumbers` - One or more recipient phone numbers in E.164 format

### Inventory Monitoring

- `inventoryThreshold` - Minimum stock level that triggers an alert (default: `10`)
- `cooldownPeriodHours` - Minimum hours before re-alerting on the same SKU (default: `24`)

### Notification Settings

- `smsTemplate` - Customizable SMS message using the placeholders below

#### SMS Template Placeholders

- `{{product.id}}` - Shopify product ID
- `{{product.name}}` - Display name of the product
- `{{product.inventory}}` - Current stock quantity
- `{{product.sku}}` - Product variant SKU
- `{{threshold}}` - Configured inventory threshold

**Default template:**
```text
INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}
```

**Example output:**
```text
INVENTORY ALERT: Blue Denim Jacket (ID: 8194105999407) is low on stock. Current inventory: 3. SKU: BDJ-001. Threshold: 10
```

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow the instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration Type** as `Trigger` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Shopify and Twilio credentials.
6. Click **Deploy** to start the integration.
7. Copy the public endpoint URL of the deployed integration.
8. In **Shopify Admin → Settings → Notifications → Webhooks**, click **Create webhook**, set **Event** to `Order creation`, **Format** to `JSON`, and paste the endpoint URL.
9. Once tested, promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
