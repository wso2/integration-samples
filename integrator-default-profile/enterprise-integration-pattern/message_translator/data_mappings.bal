function translate(SalesData salesData) returns QuickBooksInvoice => {
    customerId: salesData.customer.id,
    invoices: from var opportunity in salesData.opportunities
        select {
            id: opportunity.id,
            amount: opportunity.amount,
            invoiceDate: opportunity.closeDate
        }
};
