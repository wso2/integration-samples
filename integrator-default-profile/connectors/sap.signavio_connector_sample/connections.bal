import ballerinax/sap.signavio;

final signavio:Client signavioClient = check new ({auth: {username: username, password: password}});
