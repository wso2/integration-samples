import ballerinax/slack;
import ballerinax/trigger.github;

// Initialize Slack client
final slack:Client slackClient = check new ({
    auth: {
        token: slackToken
    }
});

// Initialize GitHub webhook listener
listener github:Listener githubListener = new ({
    "port": webhookPort,
    "callbackUrl": githubCallback
});


