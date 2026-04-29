import ballerinax/asb;

final asb:MessageReceiver asbMessagereceiver = check new ({
    connectionString: asbConnectionString,
    entityConfig: {queueName: asbQueueName}
});
