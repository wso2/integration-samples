import ballerina/log;
import ballerinax/trigger.shopify;

// Shopify webhook listener configuration
listener shopify:Listener shopifyListener = new ({
    "port": 8090,
    "apiSecretKey": shopifyConfig.shopifySecret
});

// Shopify webhook service to handle events

service shopify:CustomersService on shopifyListener {

    remote function onCustomersCreate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Received customer created event", customerId = eventId.toString());

        // Create or update Salesforce contact
        error? result = createOrUpdateSalesforceContact(event);
        if result is error {
            log:printError("Failed to create or update Salesforce contact", 'error = result, customerId = eventId.toString());
            return result;
        }
        
        log:printInfo("Successfully processed customer created event", customerId = eventId.toString());
    }

    remote function onCustomersUpdate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Received customer updated event", customerId = eventId.toString());

        // Create or update Salesforce contact with all updated details
        error? result = createOrUpdateSalesforceContact(event);
        if result is error {
            log:printError("Failed to update Salesforce contact", 'error = result, customerId = eventId.toString());
            return result;
        }
        
        log:printInfo("Successfully processed customer updated event", customerId = eventId.toString());
    }

    remote function onCustomersDelete(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer deleted", customerId = eventId.toString());
        // Add your business logic here
    }

    remote function onCustomersDisable(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer disabled", customerId = eventId.toString());
        // Add your business logic here
    }

    remote function onCustomersEnable(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer enabled", customerId = eventId.toString());
        // Add your business logic here
    }

    remote function onCustomersMarketingConsentUpdate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer marketing consent updated", customerId = eventId.toString());
        // Add your business logic here
    }
}