# Business Trip Approval

## Description

A multi-agent travel desk for business trip approvals, built with WSO2 Integrator. An employee describes a trip over HTTP. A planner agent works with three specialist agents to prepare a trip request:

- the **destination researcher** finds the place and time zone, the weather for the trip dates, and the public holidays when offices may be closed;
- the **travel advisor** checks the UK FCDO travel advice: the advice level and warnings, entry requirements, safety and health;
- the **policy analyst** checks the trip against the company travel policy, and says whether it needs a second approval.

When the employee confirms, the request goes to their manager. Long trips, and trips to places where the FCDO advises against all but essential travel, also need approval from the manager's manager. The planner pauses until every approver decides. When all approve, it issues a travel authorization that the employee takes to the company travel desk to book the trip. Nothing is booked or paid for.

All the data comes from public APIs that need no key. The only key the sample needs is for OpenAI.

## Project layout

The project is a workspace with one integration and three agent libraries:

```
business-trip-approval/
├── trip_approval/           # The integration: HTTP API, planner agent, approvals and authorizations
├── destination_researcher/  # Library: DestinationResearcherAgent (Open-Meteo, Nager.Date public holidays)
├── travel_advisor/          # Library: TravelAdvisorAgent (GOV.UK FCDO travel advice)
└── policy_analyst/          # Library: PolicyAnalystAgent (travel policy rules)
```

Each library's `README.md` describes its agent, and the functions it shares with the other packages.

## Prerequisites

- An OpenAI API key. The agents use `gpt-6-luna`.

The weather, public holiday and travel advice APIs need no keys.

## Configuration

Provide the configuration through a `Config.toml` file in the `trip_approval` directory:

```toml
openAiApiKey = "<OPENAI_API_KEY>"
```

The sample has three employees: `E1001`, a staff-grade traveler; `M2001`, their manager, a director; and `V3001`, the director's manager, a vice president. The `x-employee-id` header identifies the caller. This stands in for authentication; in production, validate a token instead.

## Usage Instructions

1. Run the integration.
2. As the employee, ask for a trip:

   ```bash
   curl -X POST http://localhost:9090/travel/chat \
     -H "Content-Type: application/json" -H "x-employee-id: E1001" \
     -d '{"sessionId": "trip-1", "message": "I need to visit a customer in Tokyo, Japan from 2027-03-08 to 2027-03-11 for a product workshop. Please prepare a trip request."}'
   ```

   The agents take about a minute. The reply describes the weather, the public holidays, the FCDO advice and entry requirements, and the policy result with who must approve, and gives a request ID such as `TRIP-35FD3195`.

3. Confirm in the same session:

   ```bash
   curl -X POST http://localhost:9090/travel/chat \
     -H "Content-Type: application/json" -H "x-employee-id: E1001" \
     -d '{"sessionId": "trip-1", "message": "Yes, submit it."}'
   ```

   The response has the status `AWAITING_APPROVAL`, and lists the pending approval with its `approvalId`, the approvers in order, and the full request.

4. As the manager, list the requests waiting for your decision:

   ```bash
   curl http://localhost:9090/travel/approvals -H "x-employee-id: M2001"
   ```

5. Set `APPROVAL_ID` to the `approvalId` from that list, and approve the request:

   ```bash
   APPROVAL_ID="paste-the-approvalId-here"
   curl -X POST "http://localhost:9090/travel/approvals/${APPROVAL_ID}" \
     -H "Content-Type: application/json" -H "x-employee-id: M2001" \
     -d '{"outcome": "APPROVE"}'
   ```

   For a short trip, the manager is the only approver: the planner resumes and replies with the travel authorization, such as `TA-34D81D47`, and its conditions. For a trip that needs a second approval, the response says the request now waits for `V3001`; repeat steps 4 and 5 as `V3001` with the same approval ID. To reject instead, send `{"outcome": "REJECT", "reason": "..."}`; the planner tells the employee who rejected it and why. Only the approver whose turn it is can decide: any other caller gets `403 Forbidden`.

6. Read the request, its authorization and its audit trail, as the traveler or one of its approvers. Set `REQUEST_ID` to the request ID from step 2:

   ```bash
   REQUEST_ID="paste-the-requestId-here"
   curl "http://localhost:9090/travel/requests/${REQUEST_ID}" -H "x-employee-id: E1001"
   ```

To see the second approval, ask for a trip longer than 10 days. To see a blocked request, ask for a trip to a country where the FCDO advises against all travel.

## How It Works

- The planner and its specialists are separate agents. The specialists are agent definitions in library packages, which the planner calls as tools.
- The policy checks are ordinary code in `policy_analyst`. The agents explain the result, but never decide it. The planner records a trip request with `createTripRequest`, which runs the policy check again, so the request holds the result the approvers see. A request with a blocker cannot be submitted.
- Submitting is the planner's `submitTripRequest` tool, marked `@ai:AgentTool {requiresApproval: true}`. When the planner calls it, the run pauses and the HTTP API returns the pending approval. The integration, not the model, routes the approval: first to the traveler's manager, then, when the policy asks for it, to the manager's manager. The last approval resumes the run, and the tool issues the authorization.
- The model chooses which request to submit, so before any approver sees it, the integration checks that the request belongs to the traveler, can be submitted, and is not already decided or waiting for a decision. The check and the reservation happen in one step, so two conversations cannot submit the same request, and the request stays reserved until its decision is finished.
- Before issuing the authorization, the integration checks the FCDO advice again. If the FCDO now advises against all travel, or newly advises against all but essential travel, the request is `STOPPED` instead, and the employee needs a new request.
- A decision is made once. Deciding an approval again returns `403 Forbidden` or `404 Not Found`, and an approval for a request that has changed since it was submitted is closed without changing the request.
- The employee directory and the travel policy are stand-ins for an HR system and a policy service. Requests, approvals and conversation history are kept in memory, so they last only while the integration runs.
