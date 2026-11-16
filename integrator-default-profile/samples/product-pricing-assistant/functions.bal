import ballerina/ai;

final readonly & map<decimal> samplePriceList = {
    "Starter": 5.00,
    "Pro": 9.00,
    "Business": 12.00,
    "Enterprise": 20.00
};

# Retrieves the most relevant passages from the product catalog for a query.
#
# + query - the question or feature to search the product catalog for
# + return - the matching catalog passages, or an error if retrieval failed
@ai:AgentTool
isolated function retrieveProductCatalog(string query) returns string|error {
    ai:QueryMatch[] matches = check productCatalogKnowledgeBase.retrieve(query, 3);
    string[] excerpts = [];
    foreach ai:QueryMatch 'match in matches {
        excerpts.push('match.chunk.content.toString());
    }
    return string:'join("\n---\n", ...excerpts);
}

# Looks up the list price per user per month for a plan from the sample price list.
#
# + planName - the name of the plan, e.g. "Business"
# + return - the price per user per month, or an error if the plan is unknown
@ai:AgentTool
isolated function lookupPlanPrice(string planName) returns decimal|error {
    decimal? price = samplePriceList[planName];
    if price is decimal {
        return price;
    }
    return error("No price found for plan " + planName);
}

# Calculates the total monthly price for a plan at a given number of users.
#
# + planName - the name of the plan being quoted
# + userCount - the number of users to quote for
# + return - the calculated price quote, or an error if the plan or user count is invalid
@ai:AgentTool
isolated function calculatePlanQuote(string planName, int userCount) returns PriceQuote|error {
    if userCount <= 0 {
        return error("User count must be positive");
    }
    decimal pricePerUser = check lookupPlanPrice(planName);
    PriceQuote quote = {
        planName: planName,
        pricePerUserPerMonth: pricePerUser,
        userCount: userCount,
        totalPricePerMonth: pricePerUser * <decimal>userCount
    };
    return quote;
}
