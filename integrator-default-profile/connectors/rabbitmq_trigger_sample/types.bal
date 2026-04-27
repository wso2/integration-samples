import ballerinax/rabbitmq;

type RabbitMQMessage record {|
    string routingKey;
    string content;
|};

type RabbitMQAnydataMessage record {|
    *rabbitmq:AnydataMessage;
    RabbitMQMessage content;
|};
