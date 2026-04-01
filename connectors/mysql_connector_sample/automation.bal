import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check mysqlClient->execute(`INSERT INTO users (name, email) VALUES ("John Doe", "john@example.com")`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
