import ballerinax/ardoq;

final ardoq:Client ardoqClient = check new ({
    auth: {
        token: token
    }
}, string `${serviceUrl}`);
