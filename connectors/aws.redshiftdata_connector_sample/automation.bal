import ballerina/log;
import ballerina/sql;
import ballerinax/aws.redshiftdata;

public function main() returns error? {
    do {
        redshiftdata:ExecutionResponse redshiftdataExecutionresponse = check redshiftdataClient->execute(`SELECT * FROM public.users LIMIT 10`, dbAccessConfig = "{id: \"\", database: \"dev\"}", statementName = "\"executeRedshiftQuery\"", withEvent = false);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
