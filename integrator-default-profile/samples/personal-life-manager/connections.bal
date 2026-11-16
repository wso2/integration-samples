import ballerina/http;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.tasks as gtasks;

final gmail:Client gmailClient = check new ({
    auth: {
        refreshToken: gmailRefreshToken,
        clientId: gmailClientId,
        clientSecret: gmailClientSecret
    }
});

final calendar:Client calendarClient = check new (config = {
    auth: {
        refreshUrl: "https://oauth2.googleapis.com/token",
        clientId: calendarClientId,
        clientSecret: calendarClientSecret,
        refreshToken: calendarRefreshToken
    }
});

final http:Client groqAudioClient = check new ("https://api.groq.com", {
    auth: {token: groqApiKey}
});

final gtasks:Client tasksClient = check new ({
    auth: {
        clientId: tasksClientId,
        clientSecret: tasksClientSecret,
        refreshUrl: "https://oauth2.googleapis.com/token",
        refreshToken: tasksRefreshToken
    }
});
