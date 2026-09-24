import ballerinax/sap.successfactors.ecworkflow;

final ecworkflow:Client ecworkflowClient = check new ({auth: {username: userName, password: password}}, hostname);
