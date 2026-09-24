import ballerinax/sap.successfactors.ecmasterdatareplication;

final ecmasterdatareplication:Client ecmasterdatareplicationClient = check new ({auth: {username: userName, password: password}}, hostname);
