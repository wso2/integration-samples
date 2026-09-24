import ballerinax/sap.successfactors.ecpaymentinformation;

final ecpaymentinformation:Client ecpaymentinformationClient = check new ({auth: {username: userName, password: password}}, hostname);
