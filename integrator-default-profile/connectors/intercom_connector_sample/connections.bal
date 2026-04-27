import ballerinax/intercom;

final intercom:Client intercomClient = check new ({auth: {token: intercomToken}});
