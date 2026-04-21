import ballerinax/stripe;

final stripe:Client stripeClient = check new ({auth: {token: stripeToken}});
