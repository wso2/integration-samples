import ballerinax/sap.successfactors.ecglobalassignment;

final ecglobalassignment:Client ecglobalassignmentClient = check new ({auth: {username: userName, password: password}}, hostname);
