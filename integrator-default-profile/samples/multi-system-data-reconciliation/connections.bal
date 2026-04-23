import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerinax/salesforce;

final salesforce:Client salesforceClient = check new ({
    baseUrl: sfBaseUrl,
    auth: {
        refreshUrl: sfRefreshUrl,
        refreshToken: sfRefreshToken,
        clientId: sfClientId,
        clientSecret: sfClientSecret
    }
});
final postgresql:Client postgresqlClient = check new (dbHost, dbUser, dbPassword, dbName, dbPort);
