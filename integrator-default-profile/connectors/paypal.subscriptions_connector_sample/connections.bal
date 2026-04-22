import ballerinax/paypal.subscriptions;

final subscriptions:Client subscriptionsClient = check new (
    {
        auth : {
            clientId: paypalClientId,
            clientSecret: paypalClientSecret
        }
    }
);
