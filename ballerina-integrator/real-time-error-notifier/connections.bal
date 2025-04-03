import ballerinax/slack;

final slack:Client slackClient = check new ({auth: {token: slackToken}});
