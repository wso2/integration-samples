import ballerinax/solace;

type SolaceMessagePayload record {|
    string messageId;
    string content;
    string destination;
|};

type SolaceMessage record {|
    *solace:Message;
    SolaceMessagePayload payload;
|};
