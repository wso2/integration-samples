import ballerinax/sap;

final sap:Client sapClient = check new (string `${sapUrl}`, {

});
