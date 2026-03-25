import ballerina/log;
import ballerina/sql;
import ballerinax/snowflake;

public function main() returns error? {
    do {
        stream<record {|anydata...;|}, sql:Error?> queryResult = snowflakeConnection->query(`SELECT ID, NAME, CREATED_AT FROM ANALYTICS_DB.PUBLIC.CUSTOMERS LIMIT 10`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
