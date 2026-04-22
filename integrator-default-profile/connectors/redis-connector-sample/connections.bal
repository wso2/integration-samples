import ballerinax/redis;

final redis:Client redisClient = check new (connection = string `${redisConnectionUri}`, connectionPooling = redisConnectionPooling, isClusterConnection = redisIsClusterConnection);
