import ballerinax/asana;

final asana:Client asanaClient = check new ({auth: {token: asanaToken}});
