import ballerinax/sap.successfactors.ecfoundationorganization;

final ecfoundationorganization:Client ecfoundationorganizationClient = check new ({auth: {username: userName, password: password}}, hostname);
