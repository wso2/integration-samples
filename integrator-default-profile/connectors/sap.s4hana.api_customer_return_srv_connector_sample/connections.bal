import ballerinax/sap.s4hana.api_customer_return_srv;

final api_customer_return_srv:Client apiCustomerReturnSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
