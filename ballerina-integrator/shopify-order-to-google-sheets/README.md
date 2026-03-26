# Update a Google Sheet when a new Shopify Order is Created

## Description

This integration listens for new order creation events from Shopify and inserts the new order details to a given google sheet, with capability to selectively filter orders that are recorded based on criteria such as payment status, currency, etc.

### What it does

- Receives order events through Shopify webhook
- Optionally filters orders by country, currency, source, status, or tags
- Appends or upserts order details to a specified Google Sheet
- Optionally expands line items into separate rows

## Prerequisites

Before running this integration, you need:

### Shopify Setup

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'.
4. Create a webhook for the **Order creation** event with the format set to **JSON** and the URL set to the deployed integration's endpoint URL.

### Google Sheets Setup

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
3. Scopes Required
  - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

## Configuration

The following configurations are required for the integration:

### Shopify Configuration
- `shopifyConfig.webhookSecret` (required): The API secret key obtained from the Shopify setup.

### Google Sheets Configuration

- `googleSheetsConfig.clientID` (required): Your Google OAuth2 client ID
- `googleSheetsConfig.clientSecret` (required): Your Google OAuth2 client secret
- `googleSheetsConfig.refreshToken` (required): Your Google OAuth2 refresh token
- `googleSheetsConfig.sheetID` (required): The Google spreadsheet ID

### Sheet Settings

- `sheetName` (optional): The tab name within a Google spreadsheet (default: "Orders")
- `insertMode` (optional): Mode to insert new orders - "append" or "upsert" (replaces row if same order_number exists) (default: "append")

### Additional Configurations

#### Data Formatting Options

- `includeLineItems` (optional): Include individual line items from orders (default: false)
- `dateFormat` (optional): Date format for output - "default" (keeps Shopify format), "iso8601", or "rfc5322" (RFC 5322 format) (default: "default")
- `groupByMonth` (optional): Organize orders into monthly sheets (format: YYYY-MM) based on order creation date. When enabled, sheets are automatically created if they don't exist (default: false)

#### Filter Configurations

All filter configurations are optional. Empty arrays mean no filtering is applied.

- `allowedCountryCodes` (optional): Array of country codes to include (e.g., ["US", "CA", "GB"]). Orders from other countries will be excluded.
- `allowedCurrencies` (optional): Array of currencies to include (e.g., ["USD", "CAD"]). Orders in other currencies will be excluded.
- `allowedSources` (optional): Array of order sources to include (e.g., ["web", "pos"]). Orders from other sources will be excluded.
- `allowedPaymentStatuses` (optional): Array of payment statuses to include (e.g., ["paid", "authorized"]). Orders with other payment statuses will be excluded.
- `allowedFulfillmentStatuses` (optional): Array of fulfillment statuses to include (e.g., ["fulfilled", "partial"]). Orders with other fulfillment statuses will be excluded.
- `requiredTags` (optional): Array of tags where at least one must be present in the order (e.g., ["VIP", "Premium"]). Orders without any of these tags will be excluded.
- `excludedTags` (optional): Array of tags that will exclude orders (e.g., ["test", "sample"]). Orders containing any of these tags will be excluded.

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Integration as API` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required environment variables.
6. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.