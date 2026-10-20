import ballerinax/sap.s4hana.api_inspectionplan_srv;

final api_inspectionplan_srv:Client apiInspectionplanSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
