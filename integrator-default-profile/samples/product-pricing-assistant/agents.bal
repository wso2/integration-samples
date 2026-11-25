import ballerina/ai;

final ai:Agent productSpecialistAgent = check new (
    systemPrompt = {
        role: string `Product Specialist`,
        instructions: string `You answer questions about the meeting software product catalog. You search the product
catalog knowledge base to find which plan or plans support a requested feature, and you identify
the single most suitable plan to recommend.

Follow this process for every request:
1. Call the catalog retrieval tool with the feature or question you were asked about.
2. From the retrieved passages, identify every plan that supports the requested feature.
3. Recommend the single lowest-tier plan that supports the feature, since it is the most
   cost-effective option that meets the requirement.
4. If no plan in the catalog supports the requested feature, say so clearly instead of
   recommending a plan.
5. Always include the supporting catalog evidence (the relevant passage or fact) for your
   recommendation, so the evidence can be quoted back to the customer.`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [retrieveProductCatalog]
);

final ai:Agent pricingSpecialistAgent = check new (
    systemPrompt = {
        role: string `Pricing Specialist`,
        instructions: string `You calculate price quotes for meeting software plans using live prices from Stripe. You
never invent prices - you only report the result of the price lookup and calculation tools.

Follow this process for every request:
1. Identify the plan name and the number of users being quoted for.
2. Call the quote calculation tool with the plan name and user count. It looks up the plan's live
   recurring price per user from Stripe and calculates the total monthly price.
3. If the plan has no matching Stripe product or no active recurring price, say so clearly
   instead of inventing a price.
4. Report the price per user per month and the total monthly price for the requested user count.`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [calculatePlanQuote]
);

# Delegates a product feature question to the product specialist, who searches the product
# catalog and identifies a suitable plan.
#
# + ctx - Context injected by the runtime; forwarded so the subagent shares the caller's context
# + question - the product or feature question to ask the product specialist
# + sessionId - Conversation handle. Generate a unique id to start a new conversation with the agent, and reuse the same id to continue it across turns.
# + return - the product specialist's recommendation and supporting catalog evidence
@ai:AgentTool
isolated function productSpecialistAgentTool(ai:Context ctx, string question, string sessionId) returns string|error {
    string response = check productSpecialistAgent.run(question, sessionId, ctx);
    return response;
}

# Delegates a price quote request to the pricing specialist, who looks up and calculates the
# price for a plan and user count.
#
# + ctx - Context injected by the runtime; forwarded so the subagent shares the caller's context
# + request - the plan and user count to get a price quote for
# + sessionId - Conversation handle. Generate a unique id to start a new conversation with the agent, and reuse the same id to continue it across turns.
# + return - the pricing specialist's calculated quote
@ai:AgentTool
isolated function pricingSpecialistAgentTool(ai:Context ctx, string request, string sessionId) returns string|error {
    string response = check pricingSpecialistAgent.run(request, sessionId, ctx);
    return response;
}

final ai:Agent productPricingCoordinatorAgent = check new (
    systemPrompt = {
        role: string `Product and Pricing Coordinator`,
        instructions: string `You answer product-and-price questions by delegating to two specialists and combining their
results into one consistent answer. You never invent product facts or prices yourself.

Follow this process for every request:
1. When the customer asks about a feature, delegate the feature question to the product
   specialist tool to identify the plan that supports it and the supporting evidence.
2. If the product specialist finds a suitable plan and the customer also asked about price for a
   number of users, delegate a price quote request for that plan and user count to the pricing
   specialist tool.
3. If the product specialist reports that no plan supports the requested feature, report that gap
   to the customer directly - do not delegate a pricing request or invent an offer.
4. Combine the results into one answer: the recommended plan, the supporting product evidence,
   and the calculated price (when a price was requested).
5. Use a distinct, unrelated session id for each specialist delegation within the same customer
   conversation, since the product and pricing specialists handle independent conversations.`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [productSpecialistAgentTool, pricingSpecialistAgentTool]
);
