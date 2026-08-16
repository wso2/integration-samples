import ballerinax/solace.jms;

type OrderMessage record {|
    string orderId;
|};

type Message record {|
    *jms:Message;
    OrderMessage payload;
|};
