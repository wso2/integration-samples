import ballerinax/trigger.shopify;
import ballerinax/stripe;
import ballerina/log;

service shopify:CustomersService on shopifyListener {
    remote function onCustomersCreate(shopify:CustomerEvent event) returns error? {
        stripe:customers_body customer = {
            name: (event?.first_name ?: "") + " " + (event?.last_name ?: ""),
            email: event?.email
        };
        _ = check stripe->/customers.post(customer);
        log:printInfo("Customer created in Stripe for Shopify customer: " + (event?.email ?: ""));
    }

    remote function onCustomersDisable(shopify:CustomerEvent event) returns error? {
        return;
    }

    remote function onCustomersEnable(shopify:CustomerEvent event) returns error? {
        return;
    }

    remote function onCustomersMarketingConsentUpdate(shopify:CustomerEvent event) returns error? {
        return;
    }

    remote function onCustomersUpdate(shopify:CustomerEvent event) returns error? {
        return;
    }
}
