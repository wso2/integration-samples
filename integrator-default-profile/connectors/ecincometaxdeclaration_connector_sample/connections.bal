import ballerinax/sap.successfactors.ecincometaxdeclaration;

final ecincometaxdeclaration:Client ecincometaxdeclarationClient = check new ({auth: {username: userName, password: password}}, hostname);
