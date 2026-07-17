import ballerinax/sap.businessone.'service as businessone;

final businessone:Client serviceClient = check new ({companyDb: companyDb, username: username, password: password}, serviceUrl = serviceUrl);

