# Shopify to QuickBooks Transaction

## Description

This prebuilt integration automatically synchronizes Shopify orders to QuickBooks Online as transactions (e.g. Sales Receipts or Invoices). By listening for Shopify order webhooks, it enables real-time synchronization, mapping Shopify line items, shipping charges, and discounts accurately into QuickBooks to ensure consistent financial records.

### What It Does

- Receives real-time order notifications from Shopify when orders are fulfilled or paid
- Automatically creates Sales Receipts or Invoices in QuickBooks for each qualifying order
- Looks up existing QuickBooks customers by email or creates new ones automatically
- Maps Shopify products to QuickBooks items, including shipping charges, discounts, and tax codes
- Quarantines unprocessable orders for manual review without interrupting other syncs

## Prerequisites

Before running this integration, you need:

### Shopify Setup

1. A Shopify account and administrative access to create Webhooks.
2. Webhook Credentials:
  - Proceed to **Settings > Notifications > Webhooks** in the Shopify Admin Dashboard.
  - Create a new webhook for your desired event (`orders/fulfilled`).
  - Set the Endpoint URL to the generated webhook URL of this integration after deployment.
  - Scroll down and copy your **Webhook Signing Secret**.

### QuickBooks Setup

1. A QuickBooks Online account with API access
2. A QuickBooks Developer App with Accounting scope (`com.intuit.quickbooks.accounting`)
3. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Company ID (Realm ID)

This integration uses refresh token flow for auth. [Learn how to set up QuickBooks OAuth](https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0).

## Configuration

The following configurations are required to connect to Shopify and QuickBooks.

### Shopify Credentials

- `apiSecretKey` - Your Shopify webhook signing secret

### QuickBooks Credentials

- `clientId` - Your QuickBooks OAuth2 client ID
- `clientSecret` - Your QuickBooks OAuth2 client secret
- `refreshToken` - Your QuickBooks OAuth2 refresh token
- `realmId` - Your QuickBooks Company ID (Realm ID)
- `serviceUrl` - QuickBooks API base URL (required, no default). Use `https://sandbox-quickbooks.api.intuit.com` for sandbox or `https://quickbooks.api.intuit.com` for production


### Additional Settings

- `transactionType` - Type of QB transaction to create (`SALES_RECEIPT` or `INVOICE`)
- `orderStatusTrigger` - Order status to sync on (FULFILLED, PAID, COMPLETED)
- `createCustomerIfNotFound` - Auto-create QB customers if not found
- `productMappingJson` - JSON string mapping Shopify SKUs to QuickBooks Item IDs (e.g., `{"SKU-123": "qb-item-id-456"}`)
- `shippingItemName` - Name of the QuickBooks item to use for shipping charges (default: "Shipping")
- `discountItemName` - Name of the QuickBooks item to use for discount line items (default: "Discount")
- `taxConfig` - Tax code configuration including default tax code and tax mapping JSON
- `validationRules` - Order validation settings (require customer email, require line items, minimum order amount)

## Deploying on **WSO2 Cloud**

1. Sign in to your WSO2 Cloud account.
2. Create a new Integration and follow instructions in [WSO2 Cloud Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Integration as API` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Shopify and QuickBooks credentials.
6. Copy the **Webhook URL** provided by the WSO2 Cloud platform and enter it in your Shopify webhook configuration.
7. Click **Deploy** to activate the automation.
8. Once tested with a dummy order, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
