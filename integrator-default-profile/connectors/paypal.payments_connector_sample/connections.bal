import ballerinax/paypal.payments;

final payments:Client paymentsClient = check new (
    {
        auth : {
            clientId: paypalClientId,
            clientSecret: paypalClientSecret
        }
    }
);