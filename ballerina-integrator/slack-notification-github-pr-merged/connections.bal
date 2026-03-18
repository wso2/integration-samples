import ballerinax/slack;
import ballerinax/trigger.github;

// Initialize Slack client
final slack:Client slackClient = check new ({
    auth: {
        token: slackToken
    }
});

// Initialize GitHub webhook listener
// Omit callbackUrl entirely when not configured to avoid runtime failures
listener github:Listener githubListener = new (githubCallback == "" ?
    {
        "port": webhookPort,
        "webhookSecret": githubWebhookSecret
    } :
    {
        "port": webhookPort,
        "callbackUrl": githubCallback,
        "webhookSecret": githubWebhookSecret
    });
