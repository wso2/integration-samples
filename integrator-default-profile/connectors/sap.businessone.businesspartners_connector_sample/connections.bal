import ballerinax/sap.businessone.businesspartners;

final businesspartners:Client businesspartnersClient = check new ({companyDb: companyDb, username: username, password: password});

