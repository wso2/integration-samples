import ballerinax/sap.s4hana.api_inspectionmethod_srv;

final api_inspectionmethod_srv:Client apiInspectionmethodSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
