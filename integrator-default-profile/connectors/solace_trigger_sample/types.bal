import ballerinax/solace;

type OrderMessage record {|
    string orderId;
|};

type Message record {|
    *solace:Message;
    OrderMessage payload;
|};
