import ballerinax/sap.successfactors.ecdismissalprotection;

final ecdismissalprotection:Client ecdismissalprotectionClient = check new ({auth: {username: userName, password: password}}, hostname);
