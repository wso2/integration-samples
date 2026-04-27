import ballerinax/openai.finetunes;

final finetunes:Client finetunesClient = check new ({auth: {token: openaiFineTunesApiToken}});
