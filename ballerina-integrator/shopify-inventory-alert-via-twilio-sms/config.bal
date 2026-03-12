configurable record {
    string storeUrl;
    string accessToken;
    string apiSecretKey;
} shopifyConfig = ?;

configurable record {
    string accountSid;
    string authToken;
    string fromNumber;
    string[] recipientNumbers;
} twilioConfig = ?;

// Inventory threshold configuration
configurable int inventoryThreshold = 10;

// SMS template with placeholders: {{product.name}}, {{product.inventory}}, {{product.sku}}
configurable string smsTemplate = "INVENTORY ALERT: {{product.name}} (ID: {{product.id}}) is low on stock. Current inventory: {{product.inventory}}. SKU: {{product.sku}}. Threshold: {{threshold}}";

// Cooldown period in hours (don't re-alert same SKU within X hours)
configurable decimal cooldownPeriodHours = 24.0;
