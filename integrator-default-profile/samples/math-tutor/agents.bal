import ballerina/ai;

final ai:Agent mathTutorAgent = check new (
    systemPrompt = {
        role: "Math Tutor",
        instructions: string `You are a math tutor assistant who helps students solve math problems. Provide clear, step-by-step instructions to guide them toward the final answer. Be sure to include the final answer at the end. Use the available tools to perform any necessary calculations.`
    }, model = mathTutorModel, tools = [sumTool, subtractTool, multTool, divideTool]
);

# Provide sum of two numbers
#
# + num1 - The first number
# + num2 - The second number
# + return - The sum of num1 and num2
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function sumTool(float num1, float num2) returns float {
    return num1 + num2;
}

# Subtract second number from the first number
#
# + num1 - The first number
# + num2 - The second number
# + return - The difference of num1 and num2
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function subtractTool(float num1, float num2) returns float {
    return num1 - num2;
}

# Provide multiplication of two numbers
#
# + num1 - The first number
# + num2 - The second number
# + return - The product of num1 and num2
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function multTool(float num1, float num2) returns float {
    return num1 * num2;
}

# Divide first number by second number
#
# + num1 - The dividend (numerator)
# + num2 - The divisor (denominator)
# + return - The quotient of num1 divided by num2, or an error if num2 is zero
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function divideTool(float num1, float num2) returns float|error {
    if num2 == 0.0 {
        return error("Cannot divide by zero");
    }
    return num1 / num2;
}
