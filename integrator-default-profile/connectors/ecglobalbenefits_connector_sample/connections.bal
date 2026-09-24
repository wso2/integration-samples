import ballerinax/sap.successfactors.ecglobalbenefits;

final ecglobalbenefits:Client ecglobalbenefitsClient = check new ({auth: {username: userName, password: password}}, hostname);
