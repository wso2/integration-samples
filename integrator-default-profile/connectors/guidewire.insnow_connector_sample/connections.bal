import ballerinax/guidewire.insnow;

final insnow:Client insnowClient = check new ({auth: {token: insnowAuthToken}}, string `${insnowServiceUrl}`);
