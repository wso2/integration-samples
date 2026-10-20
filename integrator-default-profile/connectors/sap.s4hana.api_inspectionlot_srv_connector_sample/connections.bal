import ballerinax/sap.s4hana.api_inspectionlot_srv;

final api_inspectionlot_srv:Client apiInspectionlotSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
