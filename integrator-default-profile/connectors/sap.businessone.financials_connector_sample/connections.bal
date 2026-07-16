import ballerinax/sap.businessone.financials;

final financials:Client financialsClient = check new ({companyDb: sapCompanyDb, username: sapUsername, password: sapPassword}, serviceUrl = string `${sapServiceUrl}`);

