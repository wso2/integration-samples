import ballerina/log;
import ballerina/sql;
import ballerinax/postgresql;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check postgresqlClient->execute(`INSERT INTO orders (orderId, orderAmount, orderStatus) VALUES ('ORD001', 150.00, 'pending')`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
