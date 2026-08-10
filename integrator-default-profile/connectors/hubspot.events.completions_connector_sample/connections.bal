import ballerinax/hubspot.events.completions;

final completions:Client completionsClient = check new ({auth: {token: accessToken}});
