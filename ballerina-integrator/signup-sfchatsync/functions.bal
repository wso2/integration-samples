
function getFormattedChatMessage(User payload) returns json {
    return {
        "header": {
            "title": "New Sign Up!"
        },
        "sections": [
            {
            "collapsible": false,
            "uncollapsibleWidgetsCount": 1,
            "widgets": [
                {
                "decoratedText": {
                    "icon": {
                    "knownIcon": "PERSON"
                    },
                    "text": payload.firstName + " " + payload.lastName
                }
                },
                {
                "decoratedText": {
                    "icon": {
                        "knownIcon": "EMAIL"
                    },
                    "text": payload.email
                }
                }
            ]
            }
        ]
    };
}
