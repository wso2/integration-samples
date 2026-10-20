import ballerinax/sap.s4hana.api_masterinspcharacteristic_srv;

final api_masterinspcharacteristic_srv:Client apiMasterinspcharacteristicSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
