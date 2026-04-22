import ballerinax/zoom.meetings;

final meetings:Client meetingsClient = check new ({auth: {clientId: zoomClientId, clientSecret: zoomClientSecret, refreshToken: zoomRefreshToken, refreshUrl: zoomRefreshUrl}});
