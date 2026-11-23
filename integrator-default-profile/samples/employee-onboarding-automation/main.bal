import ballerina/http;
import ballerina/log;

// NOTE: This listener has no authentication. Intended for local/development use only.
// Before exposing to a network, place it behind a reverse proxy with authentication.
listener http:Listener httpListener = new (9090);

service /onboarding on httpListener {

    # Phase 1 trigger: receives candidate data from an HR system or form webhook.
    # POST /onboarding/candidates
    # Body: {"name":"...","email":"...","address":"...","jobTitle":"...","department":"...","salary":...,"bankingInfo":"..."}
    resource function post candidates(@http:Payload CandidatePayload candidate)
            returns json|http:Conflict|http:InternalServerError {
        string|error lookupResult = lookupCandidateByEmail(candidate.email);
        if lookupResult is string && lookupResult != "NOT_FOUND" {
            return <http:Conflict>{body: {"error": string `Candidate with email ${candidate.email} already exists.`}};
        }

        // Save all candidate fields (including bankingInfo) directly to Sheets —
        // sensitive fields are not forwarded to the LLM.
        string|error saveResult = saveCandidateToSheets(
            candidate.name, candidate.email, candidate.address,
            candidate.jobTitle, candidate.department,
            candidate.salary.toString(), candidate.bankingInfo
        );
        if saveResult is error {
            log:printError("Failed to save candidate to Sheets", 'error = saveResult);
            return <http:InternalServerError>{body: {"error": saveResult.message()}};
        }

        string prompt = string `Generate and send an offer letter for a new candidate:
            name=${candidate.name}
            email=${candidate.email}
            jobTitle=${candidate.jobTitle}
            department=${candidate.department}
            salary=${candidate.salary.toString()}
            address=${candidate.address}`;

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
    resource function post check\-acceptance()
            returns json|http:ServiceUnavailable|http:InternalServerError {
        if !tryAcquirePollingLock() {
            return <http:ServiceUnavailable>{body: {"error": "Acceptance check already in progress. Try again shortly."}};
        }
        error? err = ();
        do {
            check processAcceptanceEmails();
        } on fail error e {
            err = e;
        }
        releasePollingLock();
        if err is error {
            log:printError("Acceptance check failed", 'error = err);
            return <http:InternalServerError>{body: {"error": err.message()}};
        }
        return {status: "success", message: "Acceptance check completed."};
    }

    # Health check endpoint.
    resource function get health() returns json {
        return {"status": "ok", "service": "employee-onboarding"};
    }
}
