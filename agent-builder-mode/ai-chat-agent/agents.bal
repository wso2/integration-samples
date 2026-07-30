import ballerina/ai;

final ai:Agent aiAgent = check new (
    systemPrompt = {role: string `aiagent`, instructions: string ``}, model = wso2ModelProvider, tools = []
);
