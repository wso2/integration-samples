import ballerinax/java.jms;

final jms:Connection jmsConnection = check new ({
    initialContextFactory: jmsInitialContextFactory,
    providerUrl: jmsProviderUrl
});

final jms:Session jmsSession;
final jms:MessageConsumer jmsMessageconsumer;

function init() returns error? {
    jmsSession = check jmsConnection->createSession(jms:AUTO_ACKNOWLEDGE);
    jmsMessageconsumer = check jmsSession.createConsumer(destination = {
        'type: jms:QUEUE,
        name: jmsQueueName
    });
}
