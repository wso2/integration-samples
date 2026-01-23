import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client mysqlClient = check new (string `${mysqlHost}`, string `${mysqlUser}`, string `${mysqlPassword}`, "sales_db", mysqlPort);
