import ballerina/ai;
import ballerinax/stripe;

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

# Looks up the live monthly recurring price per user for a plan from Stripe, by resolving the
# plan name to a Stripe product and reading its active recurring price.
#
# + planName - the name of the plan, e.g. "Business"
# + return - the price per user per month, or an error if the plan or its price was not found
isolated function lookupPlanPrice(string planName) returns decimal|error {
    string escapedPlanName = re `'`.replaceAll(planName, "\\'");
    stripe:SearchResult_5 productResult = check stripeClient->/products/search(
        query = string `name:'${escapedPlanName}'`,
        'limit = 100
    );
    // The search also matches longer names, such as "Business Plus" for "Business", so keep only an exact match.
    stripe:Product[] products = from stripe:Product candidate in productResult.data
        where candidate.name.toLowerAscii() == planName.toLowerAscii()
        select candidate;
    if products.length() == 0 {
        return error("No product found for plan " + planName);
    }
    stripe:Product product = products[0];
    stripe:PriceList priceList = check stripeClient->/prices(product = product.id, 'type = "recurring", active = true);
    stripe:Price[] prices = priceList.data;
    if prices.length() == 0 {
        return error("No active recurring price found for plan " + planName);
    }
    stripe:Price price = prices[0];
    int? unitAmount = price["unit_amount"];
    if unitAmount is () {
        return error("Plan " + planName + " does not have a per-unit price");
    }
    return <decimal>unitAmount / 100;
}

# Calculates the total monthly price for a plan at a given number of users, using the live price
# from Stripe.
#
# + planName - the name of the plan being quoted
# + userCount - the number of users to quote for
# + return - the calculated price quote, or an error if the plan or user count is invalid
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_stripe_2.0.1.png"}
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
