import ballerinax/sap.s4hana.api_del_doc_with_credit_block;

final api_del_doc_with_credit_block:Client apiDelDocWithCreditBlockClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
