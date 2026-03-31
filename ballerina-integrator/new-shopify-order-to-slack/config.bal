// Shopify webhook configuration
configurable ShopifyConfig shopifyConfig = ?;

// Slack configuration
configurable SlackConfig slackConfig = ?;

// Application configuration
configurable string customMessage = "🛍️ New Shopify Order Received!<br>Order ID: {orderId}<br>Customer: {customerName}<br>Items: {itemCount}<br>{items}<br>Subtotal: {currency} {subtotal}<br>Taxes: {currency} {taxes}<br>Shipping: {currency} {shipping}<br>Total: {currency} {totalPrice}<br>Shipping To: {shippingAddress}<br>Payment Status: {financialStatus}<br>Fulfillment Status: {fulfillmentStatus}<br>Created: {createdAt}";
configurable decimal minimumOrderPrice = 0.0;
