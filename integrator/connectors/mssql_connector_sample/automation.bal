import ballerina/log;
import ballerina/sql;
import ballerinax/mssql;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check mssqlClient->execute(`INSERT INTO customers (name, email) VALUES ('John Doe', 'john.doe@example.com')`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
