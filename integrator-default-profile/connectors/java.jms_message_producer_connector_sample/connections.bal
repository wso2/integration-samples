import ballerinax/java.jms;

final jms:MessageProducer jmsMessageproducer = check initJmsMessageProducer();

function initJmsMessageProducer() returns jms:MessageProducer|error {
    jms:Connection jmsConnection = check new (
        initialContextFactory = jmsInitialContextFactory,
        providerUrl = jmsProviderUrl
    );
    jms:Session jmsSession = check jmsConnection->createSession(jms:DUPS_OK_ACKNOWLEDGE);
    return check jmsSession.createProducer();
}
