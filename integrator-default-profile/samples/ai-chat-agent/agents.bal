import ballerina/ai;

final ai:Agent chatAgent = check new (
    systemPrompt = {role: "Assistant", instructions: string ``}, model = wso2ModelProvider, tools = []
);
