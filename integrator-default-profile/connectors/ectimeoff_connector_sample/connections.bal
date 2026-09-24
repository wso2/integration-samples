import ballerinax/sap.successfactors.ectimeoff;

final ectimeoff:Client ectimeoffClient = check new ({auth: {username: userName, password: password}}, hostname);
