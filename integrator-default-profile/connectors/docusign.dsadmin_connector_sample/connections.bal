import ballerinax/docusign.dsadmin;

final dsadmin:Client dsadminClient = check new ({auth: {clientId: dsadminClientId, clientSecret: dsadminClientSecret, refreshToken: dsadminRefreshToken, refreshUrl: dsadminRefreshUrl}}, string `${dsadminServiceUrl}`);
