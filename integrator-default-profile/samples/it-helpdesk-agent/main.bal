import ballerina/ai;
import ballerina/http;
import ballerina/log;

listener ai:Listener helpdeskListener = new (listenOn = check http:getDefaultListener());

service /helpdesk on helpdeskListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check helpdeskAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}

listener http:Listener approvalListener = check http:getDefaultListener();

service /approvals on approvalListener {

    // managerEmail stands in for the identity from a verified token. Anyone who can reach this endpoint can approve.
    resource function post requests/[string requestId]/decision(@http:Payload ApprovalDecision payload)
            returns AccessRequest|http:NotFound|http:Forbidden|http:Conflict {
        boolean approve = payload.decision == "approve";
        AccessRequest|NotFoundError|ForbiddenError|ConflictError result =
            decideAccessRequest(requestId, payload.managerEmail, approve, payload.comment);
        if result is NotFoundError {
            return <http:NotFound>{body: {message: result.message()}};
        }
        if result is ForbiddenError {
            return <http:Forbidden>{body: {message: result.message()}};
        }
        if result is ConflictError {
            return <http:Conflict>{body: {message: result.message()}};
        }
        log:printInfo("Access request decided", requestId = result.requestId, status = result.status);
        return result;
    }
}
