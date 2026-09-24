import ballerinax/sap.successfactors.ecpayrolltimesheets;

final ecpayrolltimesheets:Client ecpayrolltimesheetsClient = check new ({auth: {username: userName, password: password}}, hostname);
