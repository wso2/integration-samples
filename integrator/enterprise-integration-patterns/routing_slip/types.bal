type PaymentRequest record {|
    string mobileNumber;
    string customerName;
    float totalAmount;
    string storeCode;
    record {}[] items;
|};

type PaymentStatus record {|
    string status;
    record {
        float totalPoints;
        float redeemedAmount;
        float totalAmount;
    } details;
|};

type Message record {|
    string mobileNumber;
    string customerName;
    float totalAmount;
    record {
    }[] items;
    string storeCode;
    string[] routingSlip = [];
|};

type Points record {
    float loyaltyPoints = 0.0;
    float mobilePoints = 0.0;
};
