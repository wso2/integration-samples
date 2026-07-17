import ballerinax/sap.businessone.purchasing;

final purchasing:Client purchasingOrdersClient = check new ({companyDb: companyDb, username: username, password: password}, serviceUrl = serviceUrl);

