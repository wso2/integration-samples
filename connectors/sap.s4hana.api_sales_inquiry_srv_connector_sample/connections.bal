import ballerinax/sap.s4hana.api_sales_inquiry_srv;

final api_sales_inquiry_srv:Client apiSalesInquirySrvClient = check new ({auth: {username: sapS4HanaUsername, password: sapS4HanaPassword}}, string `${sapS4HanaHostname}`);
