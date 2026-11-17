import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis.chat;

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

configurable string googleChatProjectNumber = ?;
configurable string serviceAccountKeyPath = ?;

listener chat:Listener chatListener = new (8000, auth = {
    path: serviceAccountKeyPath
});

@chat:ServiceConfig {
    projectNumber: googleChatProjectNumber
}
isolated service chat:ChatService on chatListener {
    isolated remote function onMessage(chat:MessageEvent event, chat:MessageCaller caller)
            returns error? {
        check caller->respond();
        _ = start self.replyToChatMessage(event.clone(), caller);
    }

    private isolated function replyToChatMessage(chat:MessageEvent event, chat:MessageCaller caller) {
        string replyText;
        string? text = event.message.text;
        if text is () {
            replyText = "Sorry, I can only handle text messages right now.";
        } else {
            string|error result = helpdeskAgent.run(text, sessionId = "googlechat:" + (event.space?.name ?: "unknown"));
            if result is error {
                log:printError("Agent run failed", result);
                replyText = "Sorry, something went wrong. Please try again.";
            } else {
                replyText = result;
            }
        }
        chat:CreateMessageRequest reply = {text: replyText};
        chat:ChatThread? thread = event.message.thread;
        if thread is chat:ChatThread {
            reply.thread = thread;
        }
        chat:Message|error sent = caller->sendMessage(reply);
        if sent is error {
            log:printError("Google Chat send failed", sent);
        }
    }
}

