import ballerina/http;
import ballerina/uuid;
import ballerina/workflow;
import ballerina/workflow.management.rest as _;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /claims on httpDefaultListener {
    resource function post .(@http:Payload Claim claim) returns json|error {
        string claimId = uuid:createRandomUuid();
        saveClaim(claimId, claim);
        _ = check claimAgent.runWithId(claimId, "A new expense claim.", {claimId, ...claim});
        return {claimId};
    }

    resource function get [string claimId]() returns json|http:NotFound|error {
        ClaimRecord? claim = findClaim(claimId);
        if claim is () {
            return http:NOT_FOUND;
        }
        string|error summary = claimAgent.getResult(claimId);
        if summary is workflow:InstanceFailedError {
            return {claimId, status: FAILED, comment: summary.message()};
        }
        if summary is workflow:WorkflowInProgressError {
            return {claimId, status: claim.status, comment: claim.comment};
        }
        return {claimId, status: claim.status, comment: claim.comment, summary: check summary};
    }
}
