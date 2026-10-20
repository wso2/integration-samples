import ballerinax/sap.s4hana.api_qualityinforecord_srv;

final api_qualityinforecord_srv:Client apiQualityinforecordSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
