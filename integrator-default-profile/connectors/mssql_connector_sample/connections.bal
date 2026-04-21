import ballerinax/mssql;
import ballerinax/mssql.driver as _;

final mssql:Client mssqlClient = check new (string `${mssqlHost}`, string `${mssqlUser}`, string `${mssqlPassword}`, string `${mssqlDatabase}`, mssqlPort);
