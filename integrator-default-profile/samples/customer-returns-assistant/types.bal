# A customer order looked up from Shopify, with its shipped items resolved for return eligibility
# checks.
#
# + orderReference - the order reference, e.g. "#1042"
# + items - every shipped item in the order
public type Order record {|
    string orderReference;
    OrderItem[] items;
|};

# A shipped item in a customer order.
#
# + itemName - the name of the item
# + variantId - the Shopify product variant id, used to check replacement stock
# + daysSinceShipment - number of days since the item was shipped (its fulfillment was created)
public type OrderItem record {|
    string itemName;
    int variantId;
    int daysSinceShipment;
|};

# Result of a return-window eligibility check for an item.
#
# + withinReturnWindow - true when the item was shipped within the policy return window
# + daysSinceShipment - number of days since shipment that was used for the check
# + returnWindowDays - the return window, in days, used for the check
public type EligibilityResult record {|
    boolean withinReturnWindow;
    int daysSinceShipment;
    int returnWindowDays;
|};
