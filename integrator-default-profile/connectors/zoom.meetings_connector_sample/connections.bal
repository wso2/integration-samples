import ballerinax/zoom.meetings;

final meetings:Client meetingsClient = check new ({auth: {clientId: meetingsClientId, clientSecret: meetingsClientSecret, refreshToken: meetingsRefreshToken}}, string `${meetingsServiceUrl}`);
