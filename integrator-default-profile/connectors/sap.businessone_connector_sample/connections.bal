import ballerinax/sap.businessone;

final businessone:Client businessoneClient = check new (string `${sapServiceLayerUrl}`, {companyDb: sapCompanyDb, username: sapUsername, password: sapPassword});

