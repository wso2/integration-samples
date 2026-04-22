import ballerina/log;
import ballerina/sql;
import ballerinax/java.jdbc;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check jdbcClient->execute(`INSERT INTO Customers (id, name, email) VALUES (1, "John Doe", "johndoe@example.com")`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
