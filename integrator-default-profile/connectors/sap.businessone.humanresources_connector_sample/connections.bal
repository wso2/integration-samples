import ballerinax/sap.businessone.humanresources;

final humanresources:Client humanresourcesClient = check new ({
    companyDb: sapCompanyDb,
    username: sapUsername,
    password: sapPassword
}, serviceUrl = string `${sapServiceUrl}`);

