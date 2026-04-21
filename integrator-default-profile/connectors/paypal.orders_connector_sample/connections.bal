import ballerinax/paypal.orders;

final orders:Client ordersClient = check new ({auth: {clientId: paypalClientId, clientSecret: paypalClientSecret}});
