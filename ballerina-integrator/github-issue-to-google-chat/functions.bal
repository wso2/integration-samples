import ballerinax/trigger.github;

function getFormattedChatMessage(github:IssuesEvent payload) returns json {
    string labels = "";
    foreach github:Label item in payload.issue.labels {
        labels += item.name + ", ";
    }
    if labels.length() > 2 {
        labels = labels.substring(0, labels.length() - 2);
    } else {
        labels = "None";
    }
    return {
        "header": {
            "title": string `Issue #${payload.issue.number}: ${payload.issue.title}`,
            "subtitle": payload.repository.full_name,
            "imageUrl": "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
            "imageType": "CIRCLE",
            "imageAltText": "GitHub Issue"
        },
        "sections": [
            {
                "header": "Issue Details",
                "collapsible": false,
                "widgets": [
                    {
                        "decoratedText": {
                            "startIcon": {
                                "knownIcon": "PERSON"
                            },
                            "text": string `<b>Opened by: </b>${payload.issue.user.login}`
                        }
                    },
                    {
                        "decoratedText": {
                            "startIcon": {
                                "knownIcon": "BOOKMARK"
                            },
                            "text": string `<b>Labels: </b>${labels}`
                        }
                    }
                ]
            },
            {
                "widgets": [
                    {
                        "buttonList": {
                            "buttons": [
                                {
                                    "text": "View on GitHub",
                                    "icon": {
                                        "materialIcon": {
                                            "name": "open_in_new"
                                        }
                                    },
                                    "onClick": {
                                        "openLink": {
                                            "url": payload.issue.html_url
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
            }
        ]
    };
}
