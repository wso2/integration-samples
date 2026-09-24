import ballerinax/sap.successfactors.ecapprenticemanagement;

final ecapprenticemanagement:Client ecapprenticemanagementClient = check new ({auth: {username: userName, password: password}}, hostname);
