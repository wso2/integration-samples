# Shopify Inventory Alert via Twilio SMS

## Description

This integration continuously monitors inventory levels across your Shopify store and automatically sends SMS notifications via Twilio when stock falls below a defined threshold.

### What It Does

- Polls your Shopify store on a configurable interval to fetch product inventory levels
- Filters monitoring to specific products using Shopify product IDs (or monitors all products if none are specified)
- Sends SMS alerts to one or more recipient phone numbers when a product variant's inventory falls below the configured threshold
- Enforces a per-SKU cooldown period to prevent duplicate alerts within a configured time window
- Supports a fully customizable SMS message template with product-specific placeholders

## Prerequisites

Before running this integration, you need:

### Shopify Setup

1. A Shopify store with Admin API access
2. A Shopify Admin API access token with the following scopes:
   - `read_products`
   - `read_inventory`
   - `read_locations`
3. Your store's permanent `.myshopify.com` domain

To create a new app and obtain an access token, follow the [Shopify Admin API getting started guide](https://shopify.dev/docs/apps/build/authentication-authorization/access-token-types/generate-app-access-tokens-admin).

### Twilio Setup

1. A Twilio account with an active SMS-capable phone number
2. The recipient country must be enabled under **Twilio Console → Messaging → Settings → Geo Permissions**
3. For trial accounts, recipient numbers must be verified under **Twilio Console → Phone Numbers → Verified Caller IDs**

## Configuration

The following configurations are required to connect to Shopify and Twilio.

### Shopify Credentials

- `shopifyStoreUrl` - Your store URL (e.g., `https://your-store.myshopify.com`)
- `shopifyAccessToken` - Admin API access token (`shpat_...`)

### Twilio Credentials

- `twilioAccountSid` - Your Twilio Account SID (`AC...`)
- `twilioAuthToken` - Your Twilio Auth Token
- `twilioFromNumber` - Your Twilio phone number in E.164 format (e.g., `+12025551234`)
- `twilioRecipientNumbers` - One or more recipient phone numbers in E.164 format

### Inventory Monitoring

- `inventoryThreshold` - Minimum stock level that triggers an alert (default: `10`)
- `productIdsToMonitor` - Shopify product IDs to watch; empty array monitors all products
- `pollingIntervalSeconds` - How often in seconds the integration checks inventory levels (default: `300`)
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
```
INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}
```

**Example output:**
```
INVENTORY ALERT: Blue Denim Jacket (ID: 8194105999407) is low on stock. Current inventory: 3. SKU: BDJ-001. Threshold: 10
```

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow the instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration Type** as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Shopify and Twilio credentials.
6. Click **Deploy** to start the integration.
7. The monitor will run continuously, polling Shopify at the configured interval and sending SMS alerts when inventory is low.
8. Once tested, promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
