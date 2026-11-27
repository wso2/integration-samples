import ballerinax/docusign.monitor;

final monitor:Client monitorClient = check new ({auth: {clientId: monitorClientId, clientSecret: monitorClientSecret, refreshToken: monitorRefreshToken}}, string `${monitorServiceUrl}`);
