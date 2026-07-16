import ballerinax/sap.businessone.production;

final production:Client sapProductionClient = check new ({companyDb: companyDb, username: userName, password: password}, {

}, serviceUrl);

