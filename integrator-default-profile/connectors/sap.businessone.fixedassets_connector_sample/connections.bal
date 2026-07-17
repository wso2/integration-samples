import ballerinax/sap.businessone.fixedassets;

final fixedassets:Client fixedassetsClient = check new ({companyDb: sapCompanyDb, username: sapUsername, password: sapPassword}, serviceUrl = string `${sapServiceUrl}`);

