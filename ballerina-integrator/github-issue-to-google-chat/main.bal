import ballerinax/trigger.github;

listener github:Listener githubListener = new (listenerConfig = { webhookSecret: githubConfig.webhookSecret });

service github:IssuesService on githubListener {
    remote function onOpened(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onClosed(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onReopened(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onAssigned(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onUnassigned(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onLabeled(github:IssuesEvent payload) returns error|() {
        do {
            github:Label? label = payload.label;
            if label is github:Label {
                string labelName = label.name;
                if githubConfig.triggerLabels.indexOf(labelName) != () {
                    json _ = check gChatClient->/[googleChatConfig.spaceId]/messages.post(
                        {
                            cardsV2: [
                                {
                                    cardId: "issueCard", 
                                    card: getFormattedChatMessage(payload)
                                }
                            ]
                        }, key = googleChatConfig.key, token = googleChatConfig.token);
                }
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    remote function onUnlabeled(github:IssuesEvent payload) returns error|() {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
