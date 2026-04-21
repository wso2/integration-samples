import ballerinax/sap.s4hana.api_sales_quotation_srv;

final api_sales_quotation_srv:Client apiSalesQuotationSrvClient = check new ({auth: {token: sapAuthToken}}, sapHostname);
