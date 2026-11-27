# The calculated price quote for a plan at a given number of users.
#
# + planName - the name of the plan quoted
# + pricePerUserPerMonth - the list price per user, per month, for this plan
# + userCount - the number of users the quote was calculated for
# + totalPricePerMonth - the total monthly price (pricePerUserPerMonth * userCount)
public type PriceQuote record {|
    string planName;
    decimal pricePerUserPerMonth;
    int userCount;
    decimal totalPricePerMonth;
|};
