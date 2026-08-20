import ballerina/log;
import ballerinax/cdc;
import ballerinax/oracledb;
import ballerinax/oracledb.cdc.driver as _;

listener oracledb:CdcListener oracledbListener = new (database = {hostname: oracleHost, port: oraclePort, databaseName: oracleDatabase, username: oracleUser, password: oraclePassword}, options = {skippedOperations: ["u", "d"]});

@cdc:ServiceConfig {tables: "FREEPDB1.APP_USER.CUSTOMERS"}
service cdc:Service on oracledbListener {
    remote function onCreate(OracleDBInsertEntry after) returns error? {
        do {
            log:printInfo(after.toJsonString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
