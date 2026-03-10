import ballerina/log;
import ballerinax/trigger.shopify;

// Shopify webhook listener configuration
listener shopify:Listener shopifyListener = new ({
    "port": port,
    "apiSecretKey": shopifySecret
});

// Shopify webhook service to handle events

service shopify:CustomersService on shopifyListener {

    remote function onCustomersCreate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer created", customerId = eventId.toString());

        // Create Salesforce contact
        check createSalesforceContact(event);
    }

    remote function onCustomersUpdate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        log:printInfo("Customer updated", customerId = eventId.toString());
        // Add your business logic here
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

