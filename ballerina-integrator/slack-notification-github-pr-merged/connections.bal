import ballerinax/slack;
import ballerinax/trigger.github;

// Initialize Slack client
final slack:Client slackClient = check new ({
    auth: {
        token: slackConfig.token
    }
});

// Initialize GitHub webhook listener
listener github:Listener githubListener = new ({
    "port": githubConfig.port,
    "callbackUrl": githubConfig.callbackUrl,
    "repos": githubConfig.repos,
    "secret": githubConfig.webhookSecret
});
