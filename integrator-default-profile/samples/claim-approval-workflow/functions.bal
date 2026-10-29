import ballerina/log;
import ballerina/workflow;

@workflow:Activity
function recordClaim(string claimId, Claim claim) returns error? {
    log:printInfo("Claim recorded", claimId = claimId, employee = claim.employee, amount = claim.amount);
}

@workflow:Activity
function payClaim(string claimId, decimal amount) returns error? {
    log:printInfo("Claim approved and sent for payment", claimId = claimId, amount = amount);
}

@workflow:Activity
function notifyRejection(string claimId, string comment) returns error? {
    log:printInfo("Claim rejected; the employee is notified", claimId = claimId, comment = comment);
}
