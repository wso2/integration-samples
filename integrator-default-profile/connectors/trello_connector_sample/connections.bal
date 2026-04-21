import ballerinax/trello;

final trello:Client trelloClient = check new ({key: trelloApiKey, token: trelloApiToken});
