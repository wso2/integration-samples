import ballerina/log;
import ballerinax/cdc;
import ballerinax/postgresql;
import ballerinax/postgresql.cdc.driver as _;

listener postgresql:CdcListener postgresqlCdcListener = new (database = {hostname: string `${postgresHost}localhost`, port: postgresPort, username: string `${postgresUsername}`, password: string `${postgresPassword}`, databaseName: string `${postgresDatabase}`});

@cdc:ServiceConfig {
    tables: string `${postgresTable}`
}

service cdc:Service on postgresqlCdcListener {
    remote function onCreate(PostgreSQLInsertEntry afterEntry, string tableName) returns error? {
        do {
            log:printInfo(afterEntry.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
