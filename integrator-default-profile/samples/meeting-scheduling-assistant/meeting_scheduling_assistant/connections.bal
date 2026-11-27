import ballerinax/googleapis.gcalendar;

final gcalendar:Client googleCalendarClient = check new ({
    auth: {
        refreshToken: calendarRefreshToken,
        clientId: calendarClientId,
        clientSecret: calendarClientSecret
    }
});
