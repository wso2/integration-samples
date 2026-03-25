# Shopify configs
configurable ShopifyConfig shopifyConfig = ?;
# Google sheets configs
configurable SheetConfig googleSheetsConfig = ?;

# Sheet name where orders should be recorded
configurable string sheetName = "Orders";
# Mode for inserting data into the sheet
configurable InsertMode insertMode = APPEND;

# Boolean flag to include individual line items. When true, creates a separate row per line item; when false (default), creates a single row per order.
configurable boolean includeLineItems = false;
# Format for date fields in the spreadsheet: "default" keeps original date received from Shopify, "iso8601" for ISO 8601 format, "email" for RFC 5322 format
configurable "default"|"rfc5322"|"iso8601" dateFormat = "default";
# When enabled, orders are organized into monthly sheets (format: YYYY-MM) based on order created_at
configurable boolean groupByMonth = false;
# Filter by country codes - empty arrays mean no filtering
configurable string[] allowedCountryCodes = [];
# Filter by currencies (ex: USD, LKR, etc.) - empty arrays mean no filtering
configurable string[] allowedCurrencies = [];
# Filter by order sources (ex: "web", "pos", "mobile", etc.) - empty arrays mean no filtering
configurable string[] allowedSources = [];
# Filter by payment status (ex: \"paid\", \"pending\", \"authorized\", \"refunded\", etc.), empty arrays mean no filtering
configurable string[] allowedPaymentStatuses = [];
# Filter by fulfillment status (ex: "fulfilled", "partial", "unfulfilled", etc.) - empty arrays mean no filtering
configurable string[] allowedFulfillmentStatuses = [];
# Order must have at least one of these tags to be included
configurable string[] requiredTags = [];
# Order is excluded if it contains at least one of these tags
configurable string[] excludedTags = [];
