import ballerinax/paypal.invoices;

final invoices:Client invoicesClient = check new ({auth: {clientId: paypalClientId, clientSecret: paypalClientSecret}});
