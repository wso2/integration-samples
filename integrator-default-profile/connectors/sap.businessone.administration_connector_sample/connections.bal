import ballerinax/sap.businessone.administration;

final administration:Client administrationClient = check new ({companyDb: sapCompanyDb, username: sapUsername, password: sapPassword}, serviceUrl = string `${sapServiceUrl}`);

