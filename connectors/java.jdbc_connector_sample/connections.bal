import ballerinax/java.jdbc;

final jdbc:Client jdbcClient = check new (string `${jdbcUrl}`, string `${dbUser}`, string `${dbPassword}`);
