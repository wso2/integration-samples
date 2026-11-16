import ballerinax/sap.s4hana.api_credit_memo_request_srv;

final api_credit_memo_request_srv:Client apiCreditMemoRequestSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
