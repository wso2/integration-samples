import ballerina/http;
import ballerina/workflow;
import ballerina/workflow.management.rest as _;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /claims on httpDefaultListener {
    resource function post .(@http:Payload Claim claim) returns json|error {
        string claimId = check workflow:run(processClaim, claim);
        return {claimId};
    }

    resource function get [string claimId]() returns json|http:NotFound|error {
        ClaimResult|error result = workflow:getResult(claimId);
        if result is workflow:InstanceNotFoundError {
            return http:NOT_FOUND;
        }
        if result is workflow:WorkflowInProgressError {
            return {claimId, status: "IN_REVIEW"};
        }
        return result;
    }
}
