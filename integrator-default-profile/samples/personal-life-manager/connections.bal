import ballerina/http;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.tasks as gtasks;

final gmail:Client gmailClient = check new ({
    auth: {
        refreshToken: googleRefreshToken,
        clientId: googleClientId,
        clientSecret: googleClientSecret
    }
});

final calendar:Client calendarClient = check new (config = {
    auth: {
        refreshUrl: "https://oauth2.googleapis.com/token",
        clientId: googleClientId,
        clientSecret: googleClientSecret,
        refreshToken: googleRefreshToken
    }
});

final http:Client groqAudioClient = check new ("https://api.groq.com", {
    auth: {token: groqApiKey}
});

final gtasks:Client tasksClient = check new ({
    auth: {
        clientId: googleClientId,
        clientSecret: googleClientSecret,
        refreshUrl: "https://oauth2.googleapis.com/token",
        refreshToken: googleRefreshToken
    }
});
