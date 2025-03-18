import ballerinax/ai.agent;

final agent:AzureOpenAiModel _mathTutorModel = check new (serviceUrl, apiKey, deploymentId, apiVersion);
final agent:Agent _mathTutorAgent = check new (
    systemPrompt = {
        role: "Math Tutor", 
        instructions: "You are a helpful customer support assistant for a tech company. " +
            "Answer customer questions about our products. " +
            "Use the tools to check product information and availability."
    }, 
    model = _mathTutorModel, 
    tools = [sum, mult, sqrt],
    verbose = true
);

@agent:Tool
@display {label: "", iconPath: ""}
isolated function sum(decimal a, decimal b) returns decimal {
    decimal result = getSum(a, b);
    return result;
}

@agent:Tool
@display {label: "", iconPath: ""}
isolated function mult(decimal a, decimal b) returns decimal {
    decimal result = getMult(a, b);
    return result;
}

@agent:Tool
@display {label: "", iconPath: ""}
isolated function sqrt(float a) returns float {
    float result = getSqrt(a);
    return result;
}
