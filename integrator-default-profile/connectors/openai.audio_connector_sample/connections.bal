import ballerinax/openai.audio;

final audio:Client audioClient = check new ({auth: {token: openaiApiToken}});
