import ballerinax/plaid;

final plaid:Client plaidClient = check new ({auth: {plaidClientId: plaidClientId, plaidSecret: plaidSecret, plaidVersion: plaidVersion}}, string `${plaidServiceUrl}`);
