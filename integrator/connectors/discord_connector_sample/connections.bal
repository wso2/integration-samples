import ballerinax/discord;

final discord:Client discordClient = check new ({auth: {token: discordToken}});
