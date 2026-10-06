import ballerinax/sap.s4hana.api_sales_order_srv;

final api_sales_order_srv:Client apiSalesOrderSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, string `${sapS4HanaHostname}`);
