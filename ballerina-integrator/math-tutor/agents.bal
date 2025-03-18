import ballerinax/ai.agent;

final agent:AzureOpenAiModel _mathTutorModel = check new (serviceUrl, apiKey, deploymentId, apiVersion);
final agent:Agent _mathTutorAgent = check new (
    systemPrompt = {
        role: "Math Tutor", 
        instructions: "You are a knowledgeable math tutor. " +
            "Help students solve math problems by providing clear explanations and using the available tools."
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
