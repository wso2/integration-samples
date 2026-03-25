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
    "port": 8090
});
