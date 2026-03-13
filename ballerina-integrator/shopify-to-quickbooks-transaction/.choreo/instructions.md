## What It Does

- Listens for Shopify order webhooks (e.g., `orders/fulfilled` or `orders/paid`)
- Looks up or automatically creates QuickBooks customers based on Shopify buyer data
- Maps Shopify line items to corresponding QuickBooks products
- Creates QuickBooks Sales Receipts or Invoices with accurate shipping, discounts, and taxes

<details>

<summary>Shopify Setup Guide</summary>

1. A Shopify account with administrative access
2. API Webhook Credentials:
  - Navigate to **Settings > Notifications > Webhooks** in Shopify
  - Create a webhook for `orders/fulfilled` or `orders/paid` in JSON format.
  - Locate the signing secret at the bottom of the page ("Your webhooks will be signed with...")
  - Copy this secret.

</details>

<details>

<summary>QuickBooks Setup Guide</summary>

1. A QuickBooks Online account
2. A QuickBooks Developer App with Accounting scope (`com.intuit.quickbooks.accounting`) enabled
3. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Company ID (Realm ID)

This integration uses refresh token flow for auth. [Learn how to set up QuickBooks OAuth](https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0).

</details>

<details>

<summary>Additional Configurations</summary>

1. `transactionType`
    - The type of QuickBooks transaction to generate. Possible values:
        - `INVOICE` (default)
        - `SALES_RECEIPT`
2. `orderStatusTrigger`
    - The status of the Shopify order that triggers the sync. Possible values:
        - `PAID` (default)
        - `FULFILLED`
        - `COMPLETED`

</details>