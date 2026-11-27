import ballerinax/microsoft.outlook.calendar;

final calendar:Client calendarClient = check new ({auth: {clientId: calendarClientId, clientSecret: calendarClientSecret, refreshToken: calendarRefreshToken, refreshUrl: calendarRefreshUrl}}, string `${calendarServiceUrl}`);
