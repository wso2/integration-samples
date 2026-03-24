## What It Does

- Listens for Shopify order webhooks (e.g., `orders/fulfilled` or `orders/paid`)
- Looks up or automatically creates QuickBooks customers based on Shopify buyer data
- Maps Shopify line items to corresponding QuickBooks products
- Creates QuickBooks Sales Receipts or Invoices with accurate shipping, discounts, and taxes

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `shopifyWebHookSecret` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Customer creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.
</details>

<details>

<summary>QuickBooks Setup Guide</summary>

1. A QuickBooks Online account
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Company ID (Realm ID)
3. Scopes required:
  - `com.intuit.quickbooks.accounting` (Accounting)

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