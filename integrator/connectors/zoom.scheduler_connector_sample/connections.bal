import ballerinax/zoom.scheduler;

final scheduler:Client zoomSchedulerClient = check new ({auth: {refreshUrl: zoomRefreshUrl, refreshToken: zoomRefreshToken, clientId: zoomClientId, clientSecret: zoomClientSecret}});
