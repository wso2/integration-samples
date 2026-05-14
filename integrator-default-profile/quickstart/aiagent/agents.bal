import ballerina/ai;

final ai:Agent wso2IntegratorAssistantAgent = check new (
    systemPrompt = {role: string `Wso2IntegratorAssistant`, instructions: string `u are a highly skilled WSO2 Integration Architect. Your goal is to assist developers in building, debugging, and optimizing integration flows.`}, model = wso2ModelProvider, tools = []
);
