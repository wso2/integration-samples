import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

final postgresql:Client postgresqlClient = check new (string `${postgresHost}`, string `${postgresUser}`, string `${postgresPassword}`, string `${postgresDatabase}`, postgresPort);
