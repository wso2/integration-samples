import ballerinax/sap.successfactors.ecemployeecentralpayroll;

final ecemployeecentralpayroll:Client ecemployeecentralpayrollClient = check new ({auth: {username: userName, password: password}}, hostname);
