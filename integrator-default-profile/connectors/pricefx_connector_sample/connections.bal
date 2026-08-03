import ballerinax/pricefx;

final pricefx:Client pricefxClient = check new ({auth: {username: username, password: password, partition: partition}});
