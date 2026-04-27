import ballerinax/kafka;

type KafkaConsumerRecord record {|
    string topic;
    string value;
|};

type KafkaAnydataConsumer record {|
    *kafka:AnydataConsumerRecord;
    KafkaConsumerRecord value;
|};
