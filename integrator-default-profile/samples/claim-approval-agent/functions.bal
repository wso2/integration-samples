import ballerina/log;
import ballerina/workflow;

// Claims are kept in memory in this sample; replace this store with your claims system.
isolated map<ClaimRecord> claims = {};

isolated function saveClaim(string claimId, Claim claim) {
    lock {
        claims[claimId] = {...claim.clone(), status: IN_REVIEW, comment: ""};
    }
    log:printInfo("Claim recorded", claimId = claimId, employee = claim.employee, amount = claim.amount);
}

isolated function findClaim(string claimId) returns ClaimRecord? {
    lock {
        return claims[claimId].clone();
    }
}

isolated function closeClaim(string claimId, ClaimStatus status, string comment) returns ClaimRecord|error {
    lock {
        ClaimRecord? claim = claims[claimId];
        if claim is () {
            return error(string `No claim with ID ${claimId}`);
        }
        claim.status = status;
        claim.comment = comment;
        return claim.clone();
    }
}

# Checks the claim against the expense policy and says whether an approver must decide on it.
#
# + claimId - The claim id
# + businessExpense - Your judgment of the description: false for personal items, gifts, family costs or alcohol
# + return - Whether approval is required, and why
@workflow:Activity
function checkPolicy(string claimId, boolean businessExpense) returns PolicyCheck|error {
    ClaimRecord? claim = findClaim(claimId);
    if claim is () {
        return error(string `No claim with ID ${claimId}`);
    }
    if claim.amount <= 0d {
        return error("The amount claimed must be positive.");
    }
    if !businessExpense {
        return {approvalRequired: true, reason: "The claim does not read as a business expense."};
    }
    if claim.amount > approvalLimit {
        return {approvalRequired: true, reason: string `The amount is above the approval limit of ${approvalLimit}.`};
    }
    return {approvalRequired: false, reason: string `The amount is within the approval limit of ${approvalLimit}.`};
}

# Pays the recorded amount of the claim.
#
# + claimId - The claim id
# + comment - The approver's comment, or empty when no approval was needed
# + return - An error if the payment fails
@workflow:Activity
function payClaim(string claimId, string comment) returns error? {
    ClaimRecord claim = check closeClaim(claimId, APPROVED, comment);
    log:printInfo("Claim approved and sent for payment", claimId = claimId, amount = claim.amount);
}

# Rejects the claim and tells the employee why.
#
# + claimId - The claim id
# + comment - The approver's comment: why the claim is rejected
# + return - An error if the employee cannot be notified
@workflow:Activity
function notifyRejection(string claimId, string comment) returns error? {
    _ = check closeClaim(claimId, REJECTED, comment);
    log:printInfo("Claim rejected; the employee is notified", claimId = claimId, comment = comment);
}
