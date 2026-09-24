import ballerinax/sap.successfactors.ecpersonalinformation;

final ecpersonalinformation:Client ecpersonalinformationClient = check new ({auth: {username: userName, password: password}}, hostname);
