import ballerinax/sap.s4hana.api_inbound_delivery_srv_0002;

final api_inbound_delivery_srv_0002:Client apiInboundDeliverySrv0002Client = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
