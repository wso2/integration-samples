import ballerinax/sap.businessone.crm;

final crm:Client crmClient = check new ({companyDb: companyDb, username: userName, password: password}, serviceUrl = serviceUrl);

