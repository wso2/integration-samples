import ballerinax/googleapis.calendar;

final calendar:Client calendarClient = check new ({auth: {refreshUrl: calendarRefreshUrl, refreshToken: calendarRefreshToken, clientId: calendarClientId, clientSecret: calendarClientSecret}});
