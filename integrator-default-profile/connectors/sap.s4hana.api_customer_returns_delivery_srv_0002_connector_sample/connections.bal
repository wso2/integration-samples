import ballerinax/sap.s4hana.api_customer_returns_delivery_srv_0002;

final api_customer_returns_delivery_srv_0002:Client apiCustomerReturnsDeliverySrv0002Client = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
