import ballerinax/zoom.scheduler;

final scheduler:Client schedulerClient = check new ({auth: {clientId: schedulerClientId, clientSecret: schedulerClientSecret, refreshToken: schedulerRefreshToken, refreshUrl: schedulerRefreshUrl}}, string `${schedulerServiceUrl}`);
