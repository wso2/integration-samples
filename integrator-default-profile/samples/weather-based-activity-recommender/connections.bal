import ballerina/http;
import ballerinax/openai.chat;

chat:Client openaiClient = check new ({
    auth: {
        token: openaiApiKey
    }
});

http:Client weatherClient = check new ("https://api.openweathermap.org");
