## What It Does

- Listens to shopify webhook notifications for order creation events.
- Appends/Upserts the order details to a given google sheet.

<details>

<summary>Shopify Setup Guide</summary>

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section.
3. Copy the key that is shown under 'Your webhooks will be signed with ...'. This should be the `apiSecretKey` configuration.

The following should be done after deploying the integration, and the endpoint URL is available.

1. Log in to your Shopify account and navigate to **Settings** > **Notifications**.
2. Click on the **Webhooks** section and click on **Create webhook**.
3. In the **Create webhook** form, select the following options:
    - **Event**: Select **Order creation** from the dropdown menu.
    - **Format**: Choose **JSON** as the format for the webhook payload.
    - **URL**: Enter the deployed integration's endpoint URL
4. Go back to the Integration Overview page, and click on **Configure Security**. Disable **OAuth2** and click on **Apply**.
</details>

<details>

<summary>Google Sheets Setup Guide</summary>

1. A Google Cloud project with Google Sheets API enabled
2. OAuth2 credentials:
    - Client ID
    - Client Secret
    - Refresh Token
3. Scopes Required
    - `https://www.googleapis.com/auth/spreadsheets`

This integration uses refresh token flow for auth. [Learn how to Develop on Google Workspace](https://developers.google.com/workspace/guides/get-started).

</details>

<details>

<summary>Additional Configurations</summary>

1. `sheetName`:
    - Name of the specific sheet (tab) within the spreadsheet where order data will be written
    - If the sheet doesn't exist, the integration will automatically create it
    - Note: This is ignored when `groupByMonth` is enabled
    - Default: `Orders`

2. `insertMode`:
    - Mode for inserting orders into the sheet
    - Possible values:
        - `append` (default) - Always adds new rows to the end of the sheet
        - `upsert` - Updates existing order rows if the order number matches, otherwise appends new rows
    - Default: `append`

3. `includeLineItems`:
    - Boolean flag to include individual line items from orders
    - When `true`, creates a separate row for each line item in an order
    - When `false` (default), creates a single row per order
    - Possible values: `true` or `false`
    - Default: `false`

4. `dateFormat`:
    - Format for date fields in the spreadsheet
    - Possible values:
        - `default` - Keeps original date received from Shopify event
        - `iso8601` - ISO 8601 format
        - `rfc5322` - RFC 5322 format
    - Default: `default`

5. `groupByMonth`:
    - Boolean flag to organize orders into monthly sheets
    - When `true`, orders are automatically routed to sheets named by their creation month (format: YYYY-MM, e.g., "2026-03")
    - Sheets are automatically created if they don't exist
    - When `false` (default), all orders go to the configured `sheetName`
    - Possible values: `true` or `false`
    - Default: `false`


</details>

<details>

<summary>Order Filters</summary>

Optional filters that can be applied to listen to orders with certain attributes.

1. `allowedCountryCodes`:
    - Filter orders by shipping address country code
    - Only orders with a matching country code will be processed
    - An empty array (default) means no filtering is applied
    - Example values: `["US", "LK", "GB"]`

2. `allowedCurrencies`:
    - Filter orders by currency
    - Only orders with a matching currency will be processed
    - An empty array (default) means no filtering is applied
    - Example values: `["USD", "LKR", "EUR"]`

3. `allowedSources`:
    - Filter orders by order source
    - Only orders with a matching source will be processed
    - An empty array (default) means no filtering is applied
    - Example values: `["web", "pos", "mobile"]`

4. `allowedPaymentStatuses`:
    - Filter orders by payment status
    - Only orders with a matching payment status will be processed
    - An empty array (default) means no filtering is applied
    - Example values: `["paid", "pending", "authorized", "refunded"]`

5. `allowedFulfillmentStatuses`:
    - Filter orders by fulfillment status
    - Only orders with a matching fulfillment status will be processed
    - An empty array (default) means no filtering is applied
    - Example values: `["fulfilled", "partial", "unfulfilled"]`

6. `requiredTags`:
    - Filter orders by required tags
    - Only orders that contain at least one of these tags will be processed
    - An empty array (default) means no filtering is applied

7. `excludedTags`:
    - Filter orders by excluded tags
    - Orders that contain any of these tags will be skipped
    - An empty array (default) means no filtering is applied

</details>
