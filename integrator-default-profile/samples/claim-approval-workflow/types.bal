public type Claim record {|
    string employee;
    string description;
    decimal amount;
|};

public type Decision record {|
    boolean approved;
    string comment;
|};

public type ClaimResult record {|
    string claimId;
    string status;
    string comment;
|};
