
type StockPriceResponse record {|
    string metadata;
    string last_updated;
    record {|
        string ticker;
        string price;
        string change_amount;
        string change_percentage;
        string volume;
    |}[] top_gainers;
    record {|
        string ticker;
        string price;
        string change_amount;
        string change_percentage;
        string volume;
    |}[] top_losers;
    record {|
        string ticker;
        string price;
        string change_amount;
        string change_percentage;
        string volume;
    |}[] most_actively_traded;
|};
