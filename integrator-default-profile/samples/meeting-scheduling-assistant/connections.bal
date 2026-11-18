import ballerinax/googleapis.calendar;

configurable string calendarClientId = ?;
configurable string calendarClientSecret = ?;
configurable string calendarRefreshToken = ?;
configurable string calendarRefreshUrl = "https://oauth2.googleapis.com/token";

final calendar:Client googleCalendarClient = check new ({
    auth: {
        clientId: calendarClientId,
        clientSecret: calendarClientSecret,
        refreshToken: calendarRefreshToken,
        refreshUrl: calendarRefreshUrl
    }
});
