import ballerinax/trigger.shopify;

shopify:ListenerConfig listenerConfig = {
    apiSecretKey: shopifyConfig.apiSecretKey
};

listener shopify:Listener shopifyListener = new (listenerConfig, 8090);

service shopify:OrdersService on shopifyListener {
    remote function onOrdersCreate(shopify:OrderEvent event) returns error? {
        check createRowFromEvent(event);
    }

    remote function onOrdersCancelled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersFulfilled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPaid(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent event) returns error? {
    }

    remote function onOrdersUpdated(shopify:OrderEvent event) returns error? {
    }
}
