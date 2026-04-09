import ballerina/log;
import ballerina/sql;
import ballerinax/oracledb;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check oracledbClient->execute(`INSERT INTO Employees (name, department) VALUES ('John Doe', 'Engineering')`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
