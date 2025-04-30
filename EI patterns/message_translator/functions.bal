function translate(SalesData salesData) returns QuickBooksInvoice {
    return {
        customerId: salesData.customer.id,
        invoices: from var oppotunity in salesData.opportunities
            select {
                id: oppotunity.id,
                amount: oppotunity.amount,
                invoiceDate: oppotunity.closeDate
            }
    };
}
