# Sample customer order used for return eligibility checks.
#
# + orderReference - the unique order reference, e.g. "ORD-1042"
# + itemName - the name of the item in the order
# + deliveredDaysAgo - number of days since the order was delivered
public type Order record {|
    string orderReference;
    string itemName;
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
