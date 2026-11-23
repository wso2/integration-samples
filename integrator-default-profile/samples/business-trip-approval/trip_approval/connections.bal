import ballerinax/ai.openai;

final openai:ModelProvider modelProvider = check new (apiKey = openAiApiKey, modelType = openai:GPT_6_LUNA,
    apiType = openai:RESPONSES);
