import ballerinax/rabbitmq;

final rabbitmq:Client rabbitmqClient = check new (string `${rabbitmqHost}`, rabbitmqPort, username = string `${rabbitmqUsername}`, password = string `${rabbitmqPassword}`, virtualHost = string `${rabbitmqVirtualHost}`);
