import ballerinax/ai.agent;

final agent:OpenAiModel _orderManagementAgentModel = check new (openAiApiKey, agent:GPT_4O);
final agent:Agent _orderManagementAgentAgent = check new (systemPrompt = {role: "Order Management Assistant", instructions: string `You are a pizza order management assistant, designed to guide cashiers through each step of the order management process, asking relevant questions to ensure orders are handled accurately and efficiently.`}, model = _orderManagementAgentModel, tools = [getPizzas, createOrder, getOrders, getOrder, updateOrder]);
