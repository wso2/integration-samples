public type Claim record {|
    string employee;
    string description;
    decimal amount;
|};

public type PolicyCheck record {|
    boolean approvalRequired;
    string reason;
|};

public type Decision record {|
    boolean approved;
    string comment;
|};
