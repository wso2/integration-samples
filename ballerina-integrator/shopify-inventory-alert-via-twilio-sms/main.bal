import ballerina/lang.runtime;
import ballerina/log;
import ballerina/time;

// Track products with cooldown period to avoid duplicate alerts
map<AlertCooldown> cooldownTracker = {};

public function main() returns error? {
    log:printInfo("Starting Shopify Inventory Monitor",
        threshold = inventoryThreshold,
        pollingInterval = pollingIntervalSeconds,
        cooldownPeriod = cooldownPeriodHours,
        recipients = twilioRecipientNumbers.length());

    if productIdsToMonitor.length() > 0 {
        log:printInfo("Monitoring specific product IDs", productIds = productIdsToMonitor);
    } else {
        log:printInfo("Monitoring all products");
    }

    while true {
        error? result = checkAndNotifyInventory();
        if result is error {
            log:printError("Error checking inventory", 'error = result);
        }

        // Wait for the next polling interval
        runtime:sleep(pollingIntervalSeconds);
    }
}

function checkAndNotifyInventory() returns error? {
    log:printDebug("Checking inventory levels");

    // Fetch products from Shopify
    Product[] allProducts = check getShopifyProducts();
    log:printDebug("Fetched products from Shopify", count = allProducts.length());

    // Filter products based on configuration
    Product[] productsToCheck = filterProducts(allProducts);
    log:printDebug("Products to monitor after filtering", count = productsToCheck.length());

    // Check inventory levels
    map<ProductInventoryInfo> lowInventoryProducts = checkInventoryLevels(productsToCheck);

    if lowInventoryProducts.length() == 0 {
        log:printDebug("All monitored products have sufficient inventory");
        return;
    }

    log:printWarn("Products with low inventory detected", count = lowInventoryProducts.length());

    // Send alerts for products that have passed cooldown period
    foreach string sku in lowInventoryProducts.keys() {
        ProductInventoryInfo productInfo = lowInventoryProducts.get(sku);

        // Check if cooldown period has expired
        if !isCooldownExpired(sku, cooldownTracker) {
            log:printDebug("Skipping alert - cooldown period active",
                product = productInfo.productName, sku = sku);
            continue;
        }

        // Send SMS alert to all recipients
        log:printInfo("Sending inventory alert",
            product = productInfo.productName, sku = sku, inventory = productInfo.inventory);
        error? sendResult = sendInventoryAlert(productInfo);

        if sendResult is error {
            log:printError("Failed to send alert",
                product = productInfo.productName, 'error = sendResult);
        } else {
            log:printInfo("Alert sent successfully", recipients = twilioRecipientNumbers.length());

            // Update cooldown tracker
            cooldownTracker[sku] = {
                lastAlertTime: time:monotonicNow(),
                inventory: productInfo.inventory
            };
        }
    }
}
