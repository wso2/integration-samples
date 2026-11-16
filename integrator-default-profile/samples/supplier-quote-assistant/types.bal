# A single supplier quotation extracted from the pasted text.
#
# + supplierName - the name or label of the supplier, e.g. "Supplier A"
# + unitPrice - the price per unit quoted, in the request's currency
# + quantity - the number of units being quoted for
# + shippingCharge - the shipping charge for the order, in the request's currency
# + deliveryDate - the quoted delivery date, e.g. "2026-11-20" or "Friday"
public type Quotation record {|
    string supplierName;
    decimal unitPrice;
    int quantity;
    decimal shippingCharge;
    string deliveryDate;
|};

# The computed total cost for a quotation.
#
# + supplierName - the name or label of the supplier
# + totalCost - the total cost (unit price * quantity + shipping charge)
public type QuotationTotal record {|
    string supplierName;
    decimal totalCost;
|};

# The result of checking a quotation's total cost against a budget.
#
# + supplierName - the name or label of the supplier
# + withinBudget - true when the total cost does not exceed the budget
# + totalCost - the total cost that was checked
# + budget - the budget it was checked against
public type BudgetCheckResult record {|
    string supplierName;
    boolean withinBudget;
    decimal totalCost;
    decimal budget;
|};

# The result of checking a quotation's delivery date against a deadline.
#
# + supplierName - the name or label of the supplier
# + meetsDeadline - true when the delivery date is on or before the deadline
# + deliveryDate - the quoted delivery date that was checked
# + deadline - the deadline it was checked against
public type DeadlineCheckResult record {|
    string supplierName;
    boolean meetsDeadline;
    string deliveryDate;
    string deadline;
|};
