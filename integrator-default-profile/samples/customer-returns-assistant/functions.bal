import ballerina/ai;

final readonly & Order[] sampleOrders = [
    {orderReference: "ORD-1042", itemName: "Wireless Headset", deliveredDaysAgo: 12},
    {orderReference: "ORD-2087", itemName: "Bluetooth Speaker", deliveredDaysAgo: 45}
];

final readonly & map<int> sampleReplacementStock = {
    "Wireless Headset": 5,
    "Bluetooth Speaker": 0
};

final int returnWindowDays = 30;

# Looks up a sample customer order by its order reference.
#
# + orderReference - the order reference to look up, e.g. "ORD-1042"
# + return - the matching order, or an error if no order was found
@ai:AgentTool
isolated function lookupOrder(string orderReference) returns Order|error {
    foreach Order 'order in sampleOrders {
        if 'order.orderReference == orderReference {
            return 'order;
        }
    }
    return error("No order found for reference " + orderReference);
}

# Checks whether an order was delivered within the policy return window.
#
# + deliveredDaysAgo - number of days since the order was delivered
# + return - the eligibility result, or an error if the delivery age is negative
@ai:AgentTool
isolated function checkReturnWindowEligibility(int deliveredDaysAgo) returns EligibilityResult|error {
    if deliveredDaysAgo < 0 {
        return error("Delivery age must not be negative");
    }
    boolean withinWindow = deliveredDaysAgo <= returnWindowDays;
    EligibilityResult result = {
        withinReturnWindow: withinWindow,
        deliveredDaysAgo: deliveredDaysAgo,
        returnWindowDays: returnWindowDays
    };
    return result;
}

# Checks how many replacement units of an item are available in sample stock.
#
# + itemName - the name of the item to check stock for
# + return - the number of replacement units available, 0 if the item is unknown
@ai:AgentTool
isolated function checkReplacementStock(string itemName) returns int {
    int? stock = sampleReplacementStock[itemName];
    if stock is int {
        return stock;
    }
    return 0;
}

# Retrieves the most relevant passages from the return policy document for a query.
#
# + query - the question or topic to search the return policy for
# + return - the matching policy passages, or an error if retrieval failed
@ai:AgentTool
isolated function retrieveReturnPolicy(string query) returns string|error {
    ai:QueryMatch[] matches = check returnPolicyKnowledgeBase.retrieve(query, 3);
    string[] excerpts = [];
    foreach ai:QueryMatch 'match in matches {
        excerpts.push('match.chunk.content.toString());
    }
    return string:'join("\n---\n", ...excerpts);
}
