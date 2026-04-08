import ballerinax/ai;

final ai:AzureOpenAiProvider _MathTutorModel = check new (serviceUrl, apiKey, deploymentId, apiVersion);
final ai:Agent _MathTutorAgent = check new (
    systemPrompt = {role: "Math Tutor", instructions: string `You are a math tutor assistant who helps students solve math problems. Provide clear, step-by-step instructions to guide them toward the final answer. Be sure to include the final answer at the end. Use the available tools to perform any necessary calculations.`}, model = _MathTutorModel, tools = [sumTool, subtractTool, multTool, divideTool]
);

# Provide sum of two numbers
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function sumTool(int num1, int num2) returns int {
    int result = sum(num1, num2);
    return result;
}

# Subtract second number from the first number
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function subtractTool(int num1, int num2) returns int {
    int result = substract(num1, num2);
    return result;
}

# Provide multiplication of two numbers
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function multTool(int num1, int num2) returns int {
    int result = mult(num1, num2);
    return result;
}

# devide first number by second number
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function divideTool(int num1, int num2) returns int {
    int result = divide(num1, num2);
    return result;
}
