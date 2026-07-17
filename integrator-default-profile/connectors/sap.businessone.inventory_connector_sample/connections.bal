import ballerinax/sap.businessone.inventory;

final inventory:Client inventoryClient = check new ({companyDb: companyDb, username: userName, password: password});

