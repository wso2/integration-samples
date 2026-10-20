import ballerinax/sap.s4hana.api_outbound_delivery_srv_0002;

final api_outbound_delivery_srv_0002:Client apiOutboundDeliverySrv0002Client = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
