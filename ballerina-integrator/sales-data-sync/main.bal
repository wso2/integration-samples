import ballerina/ftp;
import ballerina/log;
import ballerina/sql;

listener ftp:Listener ftpListener = new (protocol = ftp:FTP, host = string `${ftpHost}`, auth = {credentials: {username: string `${ftpUser}`, password: string `${ftpPassword}`}}, port = ftpPort, path = "/sales/new");

service on ftpListener {
    remote function onFileJson(SalesReport content, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
        do {
            log:printInfo(string `Processing file from ${content.storeId}`);
            foreach ItemsItem item in content.items {
                sql:ExecutionResult sqlExecutionresult = check mysqlClient->execute(`INSERT INTO Sales (store_id, store_location, sale_date, item_id, quantity, total_amount)
                VALUES (${content.storeId}, ${content.storeLocation}, ${content.saleDate},
                        ${item.itemId}, ${item.quantity}, ${item.totalAmount})`);
            }
            check caller->move(string `${fileInfo.pathDecoded}`, "/sales/processed/" + fileInfo.name);
            log:printInfo(string `File moved to processed: ${fileInfo.name}`);
        } on fail error err {
            check caller->move(string `${fileInfo.pathDecoded}`, "/sales/error/" + fileInfo.name);
            log:printInfo(string `File moved to error: ${fileInfo.name}`);
        }
    }
}
