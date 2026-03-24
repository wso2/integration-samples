// Cooldown tracking record
type AlertCooldown record {
    decimal lastAlertTime;
    int inventory;
};

// Product inventory information passed through the alert chain
type ProductInventoryInfo record {
    int productId;
    string productName;
    string variantTitle;
    string sku;
    int inventory;
};

// Per-recipient SMS delivery result
type RecipientDeliveryResult record {|
    string recipient;
    boolean success;
    string? errorDetail;
|};
