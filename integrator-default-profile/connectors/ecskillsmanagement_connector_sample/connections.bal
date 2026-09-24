import ballerinax/sap.successfactors.ecskillsmanagement;

final ecskillsmanagement:Client ecskillsmanagementClient = check new ({auth: {username: userName, password: password}}, hostname);
