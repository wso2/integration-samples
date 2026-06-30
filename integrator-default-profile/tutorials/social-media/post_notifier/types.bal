import ballerinax/rabbitmq;

public type NotificationEvent record {|
    string leaderId;
|};

public type RabbitMQAnydataMessage record {|
    *rabbitmq:AnydataMessage;
    NotificationEvent content;
|};
