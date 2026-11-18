# A customer order looked up from Shopify, with the delivery date and item resolved for return
# eligibility checks.
#
# + orderReference - the order reference, e.g. "#1042"
# + itemName - the name of the item in the order
# + variantId - the Shopify product variant id, used to check replacement stock
# + deliveredDaysAgo - number of days since the order was delivered (fulfilled)
public type Order record {|
    string orderReference;
    string itemName;
    int variantId;
    int deliveredDaysAgo;
|};

# Result of a return-window eligibility check for an order.
#
# + withinReturnWindow - true when the order was delivered within the policy return window
# + deliveredDaysAgo - number of days since delivery that was used for the check
# + returnWindowDays - the return window, in days, used for the check
public type EligibilityResult record {|
    boolean withinReturnWindow;
    int deliveredDaysAgo;
    int returnWindowDays;
|};
