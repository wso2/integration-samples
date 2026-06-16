
type SalesData record {|
    Customer customer;
    Opportunity[] opportunities;
|};

type Customer record {|
    string id;
    string name;
    string email;
|};

type Opportunity record {|
    string id;
    decimal amount;
    string closeDate;
|};

type QuickBooksInvoice record {|
    string customerId;
    Invoice[] invoices;
|};

type Invoice record {|
    string id;
    decimal amount;
    string invoiceDate;
|};
