import ballerinax/sap.s4hana.api_sales_order_simulation_srv;

final api_sales_order_simulation_srv:Client apiSalesOrderSimulationSrvClient = check new ({auth: {token: sapAuthToken}}, string `${sapHostname}`);
