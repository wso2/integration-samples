import ballerinax/sap.s4hana.api_product_srv;

final api_product_srv:Client apiProductSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
