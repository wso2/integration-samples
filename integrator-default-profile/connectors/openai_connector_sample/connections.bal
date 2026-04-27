import ballerinax/openai;

final openai:Client openaiClient = check new ({auth: {token: openaiApiKey}});
