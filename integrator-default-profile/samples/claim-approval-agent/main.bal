import ballerina/http;
import ballerina/workflow;
import ballerina/workflow.management.rest as _;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /claims on httpDefaultListener {
    resource function post .(@http:Payload Claim claim) returns json|error {
        string claimId = check claimAgent.run("A new expense claim.", claim);
        return {claimId};
    }

    resource function get [string claimId]() returns json|error {
        string|error summary = claimAgent.getResult(claimId);
        if summary is workflow:WorkflowInProgressError {
            return {claimId, status: "IN_PROGRESS"};
        }
        return {claimId, status: "COMPLETED", summary: check summary};
    }
}
