import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

service /onboarding on httpListener {

    # Phase 1 trigger: receives candidate data from an HR system or form webhook.
    # POST /onboarding/candidates
    # Body: {"name":"...","email":"...","address":"...","jobTitle":"...","department":"...","salary":...,"bankingInfo":"..."}
    resource function post candidates(@http:Payload CandidatePayload candidate) returns json|http:InternalServerError {
        string prompt = string `Process offer letter for a new candidate:
            name=${candidate.name}
            email=${candidate.email}
            address=${candidate.address}
            jobTitle=${candidate.jobTitle}
            department=${candidate.department}
            salary=${candidate.salary.toString()}
            bankingInfo=${candidate.bankingInfo}`;

        string|error result = offerLetterAgent.run(prompt);
        if result is error {
            log:printError("Offer letter agent failed", 'error = result);
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        log:printInfo("Offer letter agent completed", result = result);
        return {status: "success", message: result};
    }

    # Manual Phase 2 trigger for testing without waiting for the 60-second poll cycle.
    # POST /onboarding/check-acceptance
    resource function post check\-acceptance() returns json|http:InternalServerError {
        string|error result = acceptanceAgent.run(
            "Check unread emails for job offer acceptances and provision workspace accounts."
        );
        if result is error {
            log:printError("Acceptance agent failed", 'error = result);
            return <http:InternalServerError>{body: {"error": result.message()}};
        }
        return {status: "success", message: result};
    }

    # Health check endpoint.
    resource function get health() returns json {
        return {"status": "ok", "service": "employee-onboarding"};
    }
}
