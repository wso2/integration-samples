import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /api/v1/analytics on httpListener {
    resource function post sales(SalesData salesData) returns error? {
        QuickBooksInvoice quickBooksInvoice = translate(salesData);
        http:Response response = check quickBooks->/v3/company/REALM012/invoice.post(quickBooksInvoice, targetType = http:Response);
    }
}
