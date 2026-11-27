import ballerina/ai;
import ballerinax/stripe;

final ai:Agent productSpecialistAgent = check new (
    systemPrompt = {
        role: string `Product Specialist`,
        instructions: string `You answer questions about the meeting software plans in the product catalog below. You find which plans support a requested feature and recommend the single most suitable plan.

Product catalog:
- Starter plan, for small teams getting started with video meetings: HD video meetings for up to 10 participants, a 40-minute meeting time limit, screen sharing, and basic chat during meetings. It does not include meeting recording.
- Pro plan, for growing teams that need longer, larger meetings: HD video meetings for up to 100 participants, unlimited meeting duration, screen sharing, breakout rooms, and meeting transcripts (text only). It does not include meeting recording.
- Business plan, for organizations that need to capture and revisit meetings: HD video meetings for up to 300 participants, unlimited meeting duration, screen sharing, breakout rooms, cloud meeting recording with recordings saved automatically and shareable by link, meeting transcripts with speaker labels, and an admin usage dashboard. It is the lowest-tier plan that includes meeting recording.
- Enterprise plan, for large organizations with advanced security and support needs: HD video meetings for up to 1000 participants, unlimited meeting duration, screen sharing, breakout rooms, cloud meeting recording, meeting transcripts with speaker labels and AI summaries, single sign-on (SSO) and advanced security controls, and dedicated customer support.

Follow this process for every request:
1. Find every plan in the catalog that supports the requested feature.
2. Recommend the lowest-tier plan that supports it, because it is the most cost-effective plan that meets the requirement. The tiers from lowest to highest are Starter, Pro, Business, and Enterprise.
3. If no plan supports the feature, say so clearly instead of recommending a plan.
4. Always quote the catalog line that supports your recommendation.`
    }, model = check ai:getDefaultModelProvider()
);

# Searches Stripe products with a Stripe search query such as name:Business and returns the matching products with their ids.
# + query - The search query string. See [search query language](https://docs.stripe.com/search#search-query-language) and the list of supported [query fields for products](https://docs.stripe.com/search#query-fields-for-products)
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_stripe_3.0.0.png"}
isolated function searchProducts(string query) returns stripe:SearchResult5|error {
    stripe:SearchResult5 stripeSearchresult5 = check stripeClient->searchProducts(query = query);
    return stripeSearchresult5;
}

# Lists the active prices of a Stripe product, given the product id.
# + product - The id of the Stripe product, such as prod_123.
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_stripe_3.0.0.png"}
isolated function listPrices(string product) returns stripe:PriceList|error {
    stripe:PriceList stripePricelist = check stripeClient->listPrices(product = product, active = true);
    return stripePricelist;
}

final ai:Agent pricingSpecialistAgent = check new (
    systemPrompt = {
        role: string `Pricing Specialist`,
        instructions: string `You calculate monthly price quotes for meeting software plans from live Stripe prices. You never invent a price.

Follow this process for every request:
1. Identify the plan name and the number of users.
2. Call searchProducts with a query of the form name:'Business', using the plan name. Use only the product whose name matches the plan name exactly, ignoring case, because a search for Business can also return Business Plus.
3. Call listPrices with that product's id. Use its active recurring price. The unit_amount is the price per user per month in the smallest currency unit, such as cents, so divide it by 100 to get the price in the currency named in the currency field.
4. Calculate the total monthly price as the price per user times the number of users, and show the calculation on one line, for example: 25.00 x 40 users = 1000.00 USD per month.
5. If there is no matching product or no active recurring price, say so clearly instead of inventing a price.
6. Report the plan, the price per user per month, and the total monthly price.`
    }, model = check ai:getDefaultModelProvider(), tools = [searchProducts, listPrices]
);
final ai:Agent productPricingCoordinatorAgent = check new (
    systemPrompt = {
        role: string `Product and Pricing Coordinator`,
        instructions: string `You answer product and price questions by delegating to two specialists and combining their results into one answer. You never invent product facts or prices yourself.

Follow this process for every request:
1. When the customer asks about a feature, call askProductSpecialist with the feature question to find the plan that supports it and the supporting catalog line.
2. If the product specialist finds a plan and the customer also asked for a price for a number of users, call askPricingSpecialist with that plan and user count.
3. If no plan supports the feature, tell the customer directly. Do not ask for a price or invent an offer.
4. Combine the results into one answer: the recommended plan, the supporting catalog line, and the quote with its calculation when a price was requested.`
    }, model = check ai:getDefaultModelProvider(), tools = [askProductSpecialist, askPricingSpecialist]
);

# Asks the product specialist which plan supports a feature, with the supporting catalog line.
# + query - The request to send to the productSpecialistAgent agent.
# + return - The response from the productSpecialistAgent agent.
@ai:AgentTool
isolated function askProductSpecialist(string query) returns string|error {
    string|error response = productSpecialistAgent.run(query);
    return response;
}

# Asks the pricing specialist for a monthly price quote for a plan and a number of users.
# + query - The request to send to the pricingSpecialistAgent agent.
# + return - The response from the pricingSpecialistAgent agent.
@ai:AgentTool
isolated function askPricingSpecialist(string query) returns string|error {
    string|error response = pricingSpecialistAgent.run(query);
    return response;
}
