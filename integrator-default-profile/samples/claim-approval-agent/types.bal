import ballerina/constraint;

public type Claim record {|
    string employee;
    string description;
    @constraint:Number {minValue: 0.01}
    decimal amount;
|};

public type ClaimInput record {|
    string claimId;
    *Claim;
|};

public enum ClaimStatus {
    IN_REVIEW,
    APPROVED,
    REJECTED,
    FAILED
}

public type ClaimRecord record {|
    *Claim;
    ClaimStatus status;
    string comment;
|};

public type PolicyCheck record {|
    boolean approvalRequired;
    string reason;
|};

public type ApprovalRequest record {|
    string claimId;
    string employee;
    string description;
    decimal amount;
    string reason;
|};

public type Decision record {|
    boolean approved;
    string comment;
|};
