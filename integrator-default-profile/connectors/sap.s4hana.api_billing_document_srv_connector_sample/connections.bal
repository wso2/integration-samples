import ballerinax/sap.s4hana.api_billing_document_srv;

final api_billing_document_srv:Client apiBillingDocumentSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
