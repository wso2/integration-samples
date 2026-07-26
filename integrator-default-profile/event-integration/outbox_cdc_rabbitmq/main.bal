import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/cdc;
import ballerinax/postgresql;
import ballerinax/postgresql.cdc.driver as _;

public type User record {|
    string id;
    string email;
    string name;
|};

public type OutboxRow record {
    string id;
    string aggregate_type;
    string event_type;
    json payload;
};

listener postgresql:CdcListener postgresqlCdcListener = new (database = {
    hostname: dbHost,
    port: dbPort,
    username: dbUser,
    password: dbPassword,
    databaseName: dbName,
    includedSchemas: ["public"]
});

service /users on new http:Listener(8090) {
    resource function post register(User user) returns error? {
        string eventId = uuid:createType1AsString();
        json payload = {id: user.id, email: user.email, name: user.name};
        transaction {
            _ = check usersDb->execute(
                `INSERT INTO users (id, email, name) VALUES (${user.id}, ${user.email}, ${user.name})`);
            _ = check usersDb->execute(
                `INSERT INTO outbox (id, aggregate_type, event_type, payload)
                 VALUES (${eventId}, 'user', 'UserRegistered', ${payload.toJsonString()}::jsonb)`);
            check commit;
        }
        log:printInfo("User registered", userId = user.id, email = user.email);
    }
}

@cdc:ServiceConfig {tables: "accounts.public.outbox"}
service cdc:Service on postgresqlCdcListener {
    remote function onCreate(OutboxRow row, string tableName) returns error? {
        check rabbitmqClient->publishMessage({
            exchange: rabbitmqExchange,
            routingKey: row.event_type,
            content: row.payload
        });
        log:printInfo("Event published to RabbitMQ", eventType = row.event_type);
    }
}
