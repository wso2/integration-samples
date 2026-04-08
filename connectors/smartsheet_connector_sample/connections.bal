import ballerinax/smartsheet;

final smartsheet:Client smartsheetClient = check new ({auth: {token: smartsheetAccessToken}});
