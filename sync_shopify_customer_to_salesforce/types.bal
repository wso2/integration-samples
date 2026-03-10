type ShopifyCustomer record {
    int id;
    string email?;
    string first_name?;
    string last_name?;
    string phone?;
    record {string company?;}[] addresses?;
};

type SalesforceContact record {
    string FirstName?;
    string LastName;
    string Email?;
    string Phone?;
    string AccountId?;
    string RecordTypeId?;
    string LeadSource?;
    string OwnerId?;
};


