import ballerinax/trigger.shopify;

type ShopifyOrderEvent shopify:OrderEvent;

// Record to hold extracted order details
type OrderDetails record {|
    string orderNumber;
    boolean hasRealOrderId;
    string customerFullName;
    string customerEmail;
    string orderTotalPrice;
    string orderCurrency;
    string orderSubtotal;
    string orderTaxes;
    string orderShipping;
    int itemCount;
    string itemsDetails;
    string shippingAddress;
    string financialStatus;
    string fulfillmentStatus;
    string createdAt;
|};

// Shopify webhook configuration
type ShopifyConfig record {|
    string apiSecretKey;
|};

// Slack configuration
type SlackConfig record {|
    string token;
    string channelId;
|};
