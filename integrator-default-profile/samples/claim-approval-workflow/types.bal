import ballerina/constraint;

public type Claim record {|
    string employee;
    string description;
    @constraint:Number {minValue: 0.01}
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
