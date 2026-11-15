import ballerinax/sap.s4hana.api_debit_memo_request_srv;

final api_debit_memo_request_srv:Client apiDebitMemoRequestSrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, sapS4HanaHostname);
