type BankAccountReq record {|
    string name;
    string accountNumber;
    string routingNumber;
    string|() country;
|};

type IbanRequest record {|
    "json"|"xml" format = "json";
    string country_iso;
    string nid;
|};

type IbanResponse record {
    string bank_code;
};

type BankAccount record {
    string id;
    string|() bankCode;
    string name;
    string accountNumber;
    string routingNumber;
    string|() country;
};
