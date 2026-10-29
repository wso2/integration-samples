import ballerina/workflow;

# Records an expense claim, waits for an approver to decide on it, and then pays or rejects it.
#
# + ctx - The workflow context
# + claim - The submitted claim
# + return - The claim's outcome, or an error
@workflow:Workflow
function processClaim(workflow:Context ctx, Claim claim) returns ClaimResult|error {
    string claimId = check ctx.getWorkflowId();
    () _ = check ctx->callActivity(recordClaim, {claimId, claim});
    Decision decision = check ctx->awaitHumanTask("approveClaim",
            {claimId, employee: claim.employee, description: claim.description, amount: claim.amount},
            userRoles = approverRole, title = "Approve expense claim",
            description = string `${claim.employee} claims ${claim.amount} for ${claim.description}.`);
    if decision.approved {
        () _ = check ctx->callActivity(payClaim, {claimId, amount: claim.amount});
        return {claimId, status: "APPROVED", comment: decision.comment};
    } else {
        () _ = check ctx->callActivity(notifyRejection, {claimId, comment: decision.comment});
        return {claimId, status: "REJECTED", comment: decision.comment};
    }
}
