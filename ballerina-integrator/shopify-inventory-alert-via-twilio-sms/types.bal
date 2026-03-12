// Shopify API response types
type ShopifyProductsResponse record {
    Product[] products;
};

type Product record {
    int id;
    string title;
    string? vendor?;
    ProductVariant[] variants;
};

type ProductVariant record {
    int id;
    string title;
    int? inventory_quantity?;
    string? sku?;
};

// Shopify Inventory Level response
type ShopifyInventoryLevelsResponse record {
    InventoryLevel[] inventory_levels;
};

type InventoryLevel record {
    int? available?;
    int inventory_item_id;
    int location_id;
};

// Cooldown tracking record
type AlertCooldown record {
    decimal lastAlertTime;
    int inventory;
};

// Product inventory information
type ProductInventoryInfo record {
    int productId;
    string productName;
    string variantTitle;
    string sku;
    int inventory;
};
