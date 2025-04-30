
type CsvRequest record {|
    string org;
    string filename;
|};

type ZohoResponse record {|
    string status;
    string code;
    string message;
    record {|
        string file_id;
        string created_time;
    |} details;
|};
