import ballerina/http;

import wso2/sentiment_api;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /social\-media on httpDefaultListener {
    resource function get users() returns json|error {
        do {
            UsersType[] users = check dbClient->/users.get();
            return users.toJson();
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

    resource function post users/[int id]/posts(@http:Payload NewPost newPost) returns http:Created|http:NotAcceptable|http:NotFound|error {
        do {
            UserType[] user = check dbClient->/users.get(whereClause = `id = ${id}`);
            if user.length() == 0 {
                http:NotFound userNotFound = {body: {msg: "User not found"}};
                return userNotFound;
            }
            sentiment_api:Post postMessage = {
                text: newPost.description
            };
            sentiment_api:Sentiment sentiment = check sentimentClient->post("/api/sentiment", postMessage);
            if sentiment.label == "neg" {
                http:NotAcceptable postForbidden = {body: {msg: "Post not acceptable"}};
                return postForbidden;
            }
            int[] insertResult = check dbClient->/posts.post([
                {
                    description: newPost.description,
                    category: newPost.category,
                    tags: newPost.tags,
                    createdDate: {
                        year: 2026,
                        month: 7,
                        day: 17
                    },
                    userId: id
                }
            ]);
            check rabbitmqClient->publishMessage({
                content: {
                    "leaderId": id.toString()
                },
                routingKey: "ballerina.social.media"
            });
            http:Created createdMsg = {body: {msg: "Post successfully created"}};
            return createdMsg;

        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
