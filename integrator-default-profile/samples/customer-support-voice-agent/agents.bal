import ballerina/ai;

# Gets the current status of an order.
#
# + orderId - The order ID, for example ORD-1001
# + return - The order details, or an error if the order isn't found
@ai:AgentTool
isolated function getOrderStatus(string orderId) returns Order|error {
    Order? 'order = orders[orderId.toUpperAscii()];
    if 'order is () {
        return error(string `No order found with ID ${orderId}`);
    }
    return 'order;
}

# Gets the store's return policy.
#
# + return - The return policy
@ai:AgentTool
isolated function getReturnPolicy() returns string {
    return "Items can be returned within 30 days of delivery for a full refund. Items must be unused and in their original packaging.";
}

# Creates a support ticket for an issue the customer reports.
#
# + customerEmail - The customer's email address
# + issue - A short description of the issue
# + return - The ID of the created ticket
@ai:AgentTool
isolated function createSupportTicket(string customerEmail, string issue) returns string {
    return string `TCK-${customerEmail.length() + issue.length() + 4000}`;
}

final ai:ShortTermMemory aiShorttermmemory = check new (aiInmemoryshorttermmemorystore);

final ai:InMemoryShortTermMemoryStore aiInmemoryshorttermmemorystore = check new (20);
final ai:Agent customerSupportAgent = check new (
    systemPrompt = {
        role: string `Customer Support Assistant`,
        instructions: string `You are a friendly customer support assistant for an online store.
Help customers check their order status, understand the return policy, and raise support tickets.
Always use the provided tools to look up orders and create tickets. Never guess order details.
Keep every reply short and conversational: one or two sentences, with no Markdown, lists, or code.`
    }, memory = aiShorttermmemory, model = supportModel, tools = [getOrderStatus, getReturnPolicy, createSupportTicket]
);
