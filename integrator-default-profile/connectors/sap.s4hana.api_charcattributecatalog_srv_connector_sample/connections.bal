import ballerinax/sap.s4hana.api_charcattributecatalog_srv;

final api_charcattributecatalog_srv:Client apiCharcattributecatalogSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
