import ballerina/log;
import ballerinax/sap.s4hana.api_sales_order_simulation_srv;

public function main() returns error? {
    do {
        api_sales_order_simulation_srv:A_SalesOrderSimulationWrapper result = check apiSalesOrderSimulationSrvClient->createA_SalesOrderSimulation({SalesOrder: "1"});
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    
}
