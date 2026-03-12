import ballerina/time;
import ballerinax/shopify.admin;
import ballerinax/twilio;

// Function to fetch products from Shopify
function getShopifyProducts() returns Product[]|error {
    admin:ProductList response = check adminClient->getProducts();
    anydata productsData = response["products"];
    if productsData is () {
        return [];
    }
    admin:Product[] adminProducts = check productsData.cloneWithType();

    Product[] products = [];
    foreach admin:Product adminProduct in adminProducts {
        int id = adminProduct?.id ?: 0;
        string title = adminProduct?.title ?: "";
        string? vendor = adminProduct?.vendor;

        ProductVariant[] variants = [];
        admin:ProductVariant[]? adminVariants = adminProduct?.variants;
        if adminVariants is admin:ProductVariant[] {
            foreach admin:ProductVariant adminVariant in adminVariants {
                variants.push({
                    id: adminVariant?.id ?: 0,
                    title: adminVariant?.title ?: "",
                    inventory_quantity: adminVariant?.inventory_quantity,
                    sku: adminVariant?.sku
                });
            }
        }

        products.push({id, title, vendor, variants});
    }

    return products;
}

// Function to filter products based on configured product IDs
function filterProducts(Product[] products) returns Product[] {
    if productIdsToMonitor.length() == 0 {
        return products;
    }

    Product[] filteredProducts = [];
    foreach Product product in products {
        if productIdsToMonitor.indexOf(product.id) is int {
            filteredProducts.push(product);
        }
    }

    return filteredProducts;
}

// Function to check if inventory is below threshold
function checkInventoryLevels(Product[] products) returns map<ProductInventoryInfo> {
    map<ProductInventoryInfo> lowInventoryProducts = {};

    foreach Product product in products {
        foreach ProductVariant variant in product.variants {
            int? inventoryQuantity = variant?.inventory_quantity;
            if inventoryQuantity is int && inventoryQuantity < inventoryThreshold {
                string? sku = variant?.sku;
                string skuValue = sku is string ? sku : "";
                string productKey = skuValue != "" ? skuValue : string `${product.title} - ${variant.title}`;

                lowInventoryProducts[productKey] = {
                    productId: product.id,
                    productName: product.title,
                    variantTitle: variant.title,
                    sku: skuValue,
                    inventory: inventoryQuantity
                };
            }
        }
    }

    return lowInventoryProducts;
}

// Function to check if cooldown period has passed
function isCooldownExpired(string sku, map<AlertCooldown> cooldownTracker) returns boolean {
    AlertCooldown? cooldownInfo = cooldownTracker[sku];

    if cooldownInfo is () {
        return true;
    }

    decimal currentTime = time:monotonicNow();
    decimal timeDifference = currentTime - cooldownInfo.lastAlertTime;
    decimal cooldownSeconds = cooldownPeriodHours * 3600.0;

    return timeDifference >= cooldownSeconds;
}

// Function to format SMS message using template
function formatSmsMessage(ProductInventoryInfo productInfo) returns string {
    string:RegExp productIdPattern = re `\{\{product\.id\}\}`;
    string:RegExp productNamePattern = re `\{\{product\.name\}\}`;
    string:RegExp inventoryPattern = re `\{\{product\.inventory\}\}`;
    string:RegExp skuPattern = re `\{\{product\.sku\}\}`;
    string:RegExp thresholdPattern = re `\{\{threshold\}\}`;

    string message = smsTemplate;
    message = productIdPattern.replaceAll(message, productInfo.productId.toString());
    message = productNamePattern.replaceAll(message, productInfo.productName);
    message = inventoryPattern.replaceAll(message, productInfo.inventory.toString());
    message = skuPattern.replaceAll(message, productInfo.sku);
    message = thresholdPattern.replaceAll(message, inventoryThreshold.toString());

    return message;
}

// Function to send SMS via Twilio to multiple recipients
function sendInventoryAlert(ProductInventoryInfo productInfo) returns error? {
    string messageBody = formatSmsMessage(productInfo);

    foreach string recipientNumber in twilioRecipientNumbers {
        twilio:CreateMessageRequest messageRequest = {
            To: recipientNumber,
            From: twilioFromNumber,
            Body: messageBody
        };

        twilio:Message _ = check twilioClient->createMessage(messageRequest);
    }
}
