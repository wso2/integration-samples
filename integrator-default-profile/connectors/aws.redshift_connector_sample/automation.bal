import ballerina/log;
import ballerina/sql;
import ballerinax/aws.redshift;

public function main() returns error? {
    do {
        sql:ExecutionResult sqlExecutionresult = check redshiftClient->execute(`CREATE TABLE IF NOT EXISTS Employees (id INT PRIMARY KEY, name VARCHAR(100), department VARCHAR(50))`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
