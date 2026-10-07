import ballerina/log;
import ballerina/time;
import ballerinax/trigger.shopify;
import ballerinax/shopify.admin;
import ballerinax/twilio;

// Fetch current inventory for all variants of a product from Shopify Admin API.
function getProductInventory(int productId) returns map<ProductInventoryInfo>|error {
    admin:ProductList response = check adminClient->getProducts(ids = productId.toString());
    anydata productsData = response["products"];
    if productsData is () {
        return {};
    }
    admin:Product[] adminProducts = check productsData.cloneWithType();
    if adminProducts.length() == 0 {
        return {};
    }

    map<ProductInventoryInfo> variantInventory = {};
    admin:Product product = adminProducts[0];
    string productTitle = product?.title ?: "";
    admin:ProductVariant[]? variants = product?.variants;
    if variants is admin:ProductVariant[] {
        foreach admin:ProductVariant variant in variants {
            int variantId = variant?.id ?: 0;
            if variantId == 0 {
                continue;
            }
            int? inventoryQty = variant?.inventory_quantity;
            if inventoryQty is int {
                variantInventory[variantId.toString()] = {
                    productId: productId,
                    variantId: variantId,
                    productName: productTitle,
                    variantTitle: variant?.title ?: "",
                    sku: variant?.sku ?: "",
                    inventory: inventoryQty
                };
            }
        }
    }
    return variantInventory;
}

// Process line items from a new Shopify order: for each ordered product variant,
// fetch current inventory and send an SMS alert if below the threshold.
function processOrderedLineItems(shopify:LineItem[] lineItems) returns error? {
    map<map<ProductInventoryInfo>> inventoryCache = {};

    foreach shopify:LineItem lineItem in lineItems {
        int productId = lineItem?.product_id ?: 0;
        int variantId = lineItem?.variant_id ?: 0;
        if productId == 0 || variantId == 0 {
            continue;
        }

        // Fetch current inventory from Shopify Admin API, using cache to avoid duplicate calls
        string productIdKey = productId.toString();
        if !inventoryCache.hasKey(productIdKey) {
            map<ProductInventoryInfo>|error inventoryResult = getProductInventory(productId);
            if inventoryResult is error {
                log:printError("Failed to fetch inventory for product",
                    productId = productId, 'error = inventoryResult);
                continue;
            }
            inventoryCache[productIdKey] = inventoryResult;
        }

        ProductInventoryInfo? productInfo = inventoryCache[productIdKey][variantId.toString()];
        if productInfo is () {
            continue;
        }

        if productInfo.inventory >= inventoryThreshold {
            log:printDebug("Inventory above threshold, skipping alert",
                product = productInfo.productName,
                sku = productInfo.sku,
                inventory = productInfo.inventory,
                threshold = inventoryThreshold);
            continue;
        }

        string sku = productInfo.sku;
        string variantKey = "variant:" + productInfo.variantId.toString();

        // Skip if variant-level cooldown has not expired
        if !isCooldownExpired(variantKey) {
            log:printInfo("Skipping alert: cooldown period active for variant",
                variantId = productInfo.variantId,
                sku = sku,
                cooldownPeriodHours = cooldownPeriodHours);
            continue;
        }

        log:printWarn("Low inventory detected for ordered product",
            product = productInfo.productName,
            sku = sku,
            inventory = productInfo.inventory,
            threshold = inventoryThreshold);

        RecipientDeliveryResult[] deliveryResults = sendInventoryAlert(productInfo);
        int successCount = 0;
        decimal currentTime = time:monotonicNow();

        foreach RecipientDeliveryResult result in deliveryResults {
            if result.success {
                successCount += 1;
                lock {
                    cooldownTracker["recipient:" + result.recipient + "|variant:" + productInfo.variantId.toString()] = {
                        lastAlertTime: currentTime,
                        inventory: productInfo.inventory
                    };
                }
            } else {
                string detail = result.errorDetail ?: "unknown error";
                log:printError("Failed to send alert to recipient",
                    recipient = maskPhone(result.recipient),
                    product = productInfo.productName,
                    detail = detail);
            }
        }

        if successCount > 0 {
            log:printInfo("Inventory alert sent",
                successCount = successCount,
                totalRecipients = deliveryResults.length());
        }

        // Set variant-level cooldown when at least one recipient was successfully notified.
        // Recipients in individual cooldown were already notified recently.
        if successCount > 0 {
            lock {
                cooldownTracker[variantKey] = {
                    lastAlertTime: currentTime,
                    inventory: productInfo.inventory
                };
            }
        }
    }
}

// Function to check if cooldown period has passed
function isCooldownExpired(string key) returns boolean {
    lock {
        AlertCooldown? cooldownInfo = cooldownTracker[key];
        if cooldownInfo is () {
            return true;
        }
        decimal currentTime = time:monotonicNow();
        decimal timeDifference = currentTime - cooldownInfo.lastAlertTime;
        decimal cooldownSeconds = cooldownPeriodHours * 3600.0;
        return timeDifference >= cooldownSeconds;
    }
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

// Returns a masked representation of a phone number for safe logging.
function maskPhone(string phone) returns string {
    int len = phone.length();
    if len <= 4 {
        return "****";
    }
    string maskedPrefix = re `\d`.replaceAll(phone.substring(0, len - 4), "*");
    return maskedPrefix + phone.substring(len - 4);
}

// Send SMS via Twilio to all configured recipients.
// Returns per-recipient delivery results so callers can track cooldown state individually.
function sendInventoryAlert(ProductInventoryInfo productInfo) returns RecipientDeliveryResult[] {
    string messageBody = formatSmsMessage(productInfo);
    RecipientDeliveryResult[] results = [];

    foreach string recipientNumber in twilioConfig.recipientNumbers {
        // Skip recipients whose individual cooldown has not expired
        if !isCooldownExpired("recipient:" + recipientNumber + "|variant:" + productInfo.variantId.toString()) {
            continue;
        }

        twilio:CreateMessageRequest messageRequest = {
            To: recipientNumber,
            From: twilioConfig.fromNumber,
            Body: messageBody
        };

        twilio:Message|error sendResult = twilioClient->createMessage(messageRequest);
        if sendResult is error {
            results.push({recipient: recipientNumber, success: false, errorDetail: sendResult.message()});
        } else {
            results.push({recipient: recipientNumber, success: true, errorDetail: ()});
        }
    }
    return results;
}
