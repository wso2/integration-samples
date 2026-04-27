import ballerina/log;
import ballerinax/cdc;
import ballerinax/mssql;
import ballerinax/mssql.cdc.driver as _;

listener mssql:CdcListener mssqlCdcListener = new (database = {hostname: string `${mssqlHost}`, port: mssqlPort, username: string `${mssqlUsername}`, password: string `${mssqlPassword}`, databaseNames: [string `${mssqlDatabase}`]});

@cdc:ServiceConfig {
    tables: string `${mssqlTableName}`
}

service cdc:Service on mssqlCdcListener {
    remote function onCreate(MssqlInsertRecord afterEntry, string tableName) returns error? {
        do {
            log:printInfo(afterEntry.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
