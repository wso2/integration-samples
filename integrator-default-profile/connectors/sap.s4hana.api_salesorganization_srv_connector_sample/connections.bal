import ballerinax/sap.s4hana.api_salesorganization_srv;

final api_salesorganization_srv:Client apiSalesorganizationSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, string `${sapS4HanaHostname}`);
