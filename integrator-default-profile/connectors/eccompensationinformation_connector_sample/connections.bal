import ballerinax/sap.successfactors.eccompensationinformation;

final eccompensationinformation:Client eccompensationinformationClient = check new ({auth: {username: userName, password: password}}, hostname);
