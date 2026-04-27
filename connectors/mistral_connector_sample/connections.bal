import ballerinax/mistral;

final mistral:Client mistralClient = check new ({auth: {token: mistralApiKey}});
