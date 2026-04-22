import ballerinax/mongodb;

final mongodb:Client mongodbClient = check new (connection = "{ serverAddress: { host: mongoHost, port: mongoPort }, auth: { username: mongoUsername, password: mongoPassword, database: mongoDatabase } }");
