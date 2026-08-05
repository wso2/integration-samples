import ballerina/ai;

final ai:Agent AGENT_NAMEAgent = check new (
    systemPrompt = {role: string `AGENT_NAME`, instructions: string ``}, model = wso2ModelProvider, tools = []
);
