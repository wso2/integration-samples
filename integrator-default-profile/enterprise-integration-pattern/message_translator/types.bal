
type SalesData record {|
    Customer customer;
    Oppotunity[] opportunities;
|};

type Customer record {|
    string id;
    string name;
    string email;
|};

type Oppotunity record {|
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
