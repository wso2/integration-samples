import ballerinax/microsoft.teams;

final teams:Client teamsClient = check new ({auth: {tokenUrl: tokenUrl, clientId: clientId, clientSecret: clientSecret}});
