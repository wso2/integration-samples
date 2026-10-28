import ballerinax/ai.openai;

final openai:ModelProvider supportModel = check new (apiKey, openai:GPT_4O_MINI);
