import ballerina/log;
import ballerinax/cdc;
import ballerinax/googleapis.gmail;
import ballerinax/mssql;
import ballerinax/mssql.cdc.driver as _;

listener mssql:CdcListener mssqlCdcListener = new (options = {
    snapshotMode: "no_data",
    skippedOperations: [cdc:TRUNCATE, cdc:UPDATE, cdc:DELETE]
}, database = {hostname: string `${mssqlHost}`, port: mssqlPort, username: string `${mssqlUsername}`, password: string `${mssqlPassword}`, databaseNames: [string `${mssqlDatabase}`]});

@cdc:ServiceConfig {
    tables: string `${mssqlTxTable}`
}

service cdc:Service on mssqlCdcListener {
    remote function onCreate(Transaction afterEntry, string tableName) returns error? {
        do {
            log:printInfo(string `Create transaction event received. Transaction Id: ${afterEntry.tx_id}`);
            if afterEntry.amount > 10000.0 {
                string fraudAlert = "Fraud detected in transaction " + afterEntry.toJsonString();
                gmail:Message gmailMessage = check gmailClient->/users/[string `me`]/messages/send.post({
                    to: [mailRecipient],
                    subject: "Fraud Alert: Suspicious Transaction Detected",
                    bodyInHtml: fraudAlert
                }, prettyPrint = false);
                log:printInfo(string `Email sent. Message ID: ${gmailMessage.id}`);

            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
