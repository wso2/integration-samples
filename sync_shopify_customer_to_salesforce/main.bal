import ballerina/http;
import ballerina/log;
import ballerinax/trigger.shopify;

// Event-driven service: Listens to Shopify customer events and creates Salesforce contacts
service shopify:CustomersService on shopifyListener {

    // Triggered when a new customer signs up in Shopify
    remote function onCustomersCreate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        if eventId is int {
            log:printInfo(string `Event triggered: Shopify customer signup detected (ID: ${eventId.toString()})`);
        }

        ShopifyCustomer customer = check event.cloneWithType();
        check createSalesforceContact(customer);

        log:printInfo(string `Event processed: Salesforce contact created successfully`);
    }

    // Triggered when a customer is updated in Shopify
    remote function onCustomersUpdate(shopify:CustomerEvent event) returns error? {
        int? eventId = event?.id;
        if eventId is int {
            log:printInfo(string `Event triggered: Shopify customer updated (ID: ${eventId.toString()})`);
        }

        ShopifyCustomer customer = check event.cloneWithType();
        check updateSalesforceContact(customer);

        log:printInfo(string `Event processed: Salesforce contact updated successfully`);
    }

    remote function onCustomersDelete(shopify:CustomerEvent event) returns error? {
        // Not implemented - can be extended to handle customer deletion
    }

    remote function onCustomersDisable(shopify:CustomerEvent event) returns error? {
        // Not implemented - can be extended to handle customer disable
    }

    remote function onCustomersEnable(shopify:CustomerEvent event) returns error? {
        // Not implemented - can be extended to handle customer enable
    }

    remote function onCustomersMarketingConsentUpdate(shopify:CustomerEvent event) returns error? {
        // Not implemented - can be extended to handle marketing consent updates
    }
}

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {
}
