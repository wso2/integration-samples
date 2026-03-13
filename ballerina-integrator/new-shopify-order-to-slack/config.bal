// Shopify webhook configuration
configurable string shopifyApiSecretKey = ?;

// Slack configuration
configurable string slackToken = ?;
configurable string slackChannelId = ?;

// Custom message template with placeholders: {orderId}, {customerName}, {customerEmail}, {currency}, {totalPrice}, {itemCount}, {items}, {shippingAddress}, {financialStatus}, {fulfillmentStatus}, {createdAt}, {subtotal}, {taxes}, {shipping}
configurable string customMessage = "🛍️ New Shopify Order Received!<br>Order ID: {orderId}<br>Customer: {customerName}<br>Items: {itemCount}<br>{items}<br>Subtotal: {currency} {subtotal}<br>Taxes: {currency} {taxes}<br>Shipping: {currency} {shipping}<br>Total: {currency} {totalPrice}<br>Shipping To: {shippingAddress}<br>Payment Status: {financialStatus}<br>Fulfillment Status: {fulfillmentStatus}<br>Created: {createdAt}";

// Minimum order price threshold - only send notifications for orders above this amount (default: 0 to send all)
configurable decimal minimumOrderPrice = 0.0;
