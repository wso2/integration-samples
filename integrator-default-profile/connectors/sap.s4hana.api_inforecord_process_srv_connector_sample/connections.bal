import ballerinax/sap.s4hana.api_inforecord_process_srv;

final api_inforecord_process_srv:Client apiInforecordProcessSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
