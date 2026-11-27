import ballerinax/power.bi;

final bi:Client biClient = check new ({auth: {token: biToken}}, string `${biServiceUrl}`);
