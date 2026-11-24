import ballerinax/slack;
import ballerinax/trigger.github;

// Initialize Slack client
final slack:Client slackClient = check new ({
    auth: {
        token: slackConfig.token
    }
});

// Initialize GitHub webhook listener
listener github:Listener githubListener = new (listenerConfig = { webhookSecret: githubConfig.webhookSecret }, listenOn = 9090);
