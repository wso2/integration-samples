import ballerina/log;
import ballerina/sql;
import ballerinax/snowflake;

public function main() returns error? {
    do {
        stream<record {|anydata...;|}, sql:Error?> queryResult = snowflakeClient->query(`SELECT * FROM MY_TABLE LIMIT 10`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
