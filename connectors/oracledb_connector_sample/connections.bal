import ballerinax/oracledb;
import ballerinax/oracledb.driver as _;

final oracledb:Client oracledbClient = check new (string `${oracleHost}`, string `${oracleUser}`, string `${oraclePassword}`, string `${oracleDatabase}`, oraclePort);
