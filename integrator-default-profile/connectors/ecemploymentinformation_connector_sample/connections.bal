import ballerinax/sap.successfactors.ecemploymentinformation;

final ecemploymentinformation:Client ecemploymentinformationClient = check new ({auth: {username: userName, password: password}}, hostname);
