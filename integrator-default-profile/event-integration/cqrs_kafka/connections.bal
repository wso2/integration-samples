import ballerinax/kafka;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

final kafka:Producer resultsProducer = check new (bootstrapServers);

final postgresql:Client leaderboardDb = check new (
    host = dbHost, username = dbUser, password = dbPassword,
    database = dbName, port = dbPort
);
