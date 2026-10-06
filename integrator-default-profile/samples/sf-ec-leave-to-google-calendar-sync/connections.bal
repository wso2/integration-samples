import ballerinax/googleapis.calendar;
import ballerinax/sap.successfactors.ectimeoff;

final ectimeoff:Client ecClient = check new ({
    auth: {
        apiKey: apiKey,
        companyId: companyId,
        username: userName,
        privateKey: privateKey,
        certificate: certificate,
        tokenUrl: tokenUrl
    }
}, string `${hostName}`);
final calendar:Client calendarClient = check new ({
    auth: {
        refreshUrl: refreshUrl,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
});
