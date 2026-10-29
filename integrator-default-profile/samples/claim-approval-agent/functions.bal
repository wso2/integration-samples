import ballerina/log;
import ballerina/workflow;

# Records a new expense claim. Pass the claim id and the claim from your input.
#
# + claimId - The claim id: this run's workflow id
# + claim - The claim, from the agent's input
# + return - An error if the claim cannot be recorded
@workflow:Activity
function recordClaim(string claimId, Claim claim) returns error? {
    log:printInfo("Claim recorded", claimId = claimId, employee = claim.employee, amount = claim.amount);
}

# Checks the claim against the expense policy and says whether an approver must decide on it.
#
# + amount - The amount claimed
# + return - Whether approval is required, and why
@workflow:Activity
function checkPolicy(decimal amount) returns PolicyCheck|error {
    if amount > approvalLimit {
        return {approvalRequired: true, reason: string `The amount is above the approval limit of ${approvalLimit}.`};
    }
    return {approvalRequired: false, reason: string `The amount is within the approval limit of ${approvalLimit}.`};
}

# Pays the claim.
#
# + claimId - The claim id
# + amount - The amount to pay
# + return - An error if the payment fails
@workflow:Activity
function payClaim(string claimId, decimal amount) returns error? {
    log:printInfo("Claim approved and sent for payment", claimId = claimId, amount = amount);
}

# Rejects the claim and tells the employee why.
#
# + claimId - The claim id
# + comment - Why the claim is rejected
# + return - An error if the employee cannot be notified
@workflow:Activity
function notifyRejection(string claimId, string comment) returns error? {
    log:printInfo("Claim rejected; the employee is notified", claimId = claimId, comment = comment);
}
