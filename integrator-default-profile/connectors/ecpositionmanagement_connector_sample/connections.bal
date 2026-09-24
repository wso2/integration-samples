import ballerinax/sap.successfactors.ecpositionmanagement;

final ecpositionmanagement:Client ecpositionmanagementClient = check new ({auth: {username: userName, password: password}}, hostname);
