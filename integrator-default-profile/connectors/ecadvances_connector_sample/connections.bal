import ballerinax/sap.successfactors.ecadvances;

final ecadvances:Client ecadvancesClient = check new ({auth: {username: userName, password: password}}, hostname);
