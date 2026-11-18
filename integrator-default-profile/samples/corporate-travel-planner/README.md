# Corporate Travel Planner

## Description

A multi-agent travel desk for business trips, built with WSO2 Integrator. An employee describes a trip over HTTP. A planner agent works with three specialist agents to put together a proposal:

- the **destination researcher** checks the weather for the trip dates and the UK FCDO travel advice;
- the **logistics coordinator** finds flights and a hotel through the [Duffel](https://duffel.com) Flights and Stays APIs;
- the **policy analyst** checks the options against the company travel policy and converts the total to USD.

When the employee confirms, the booking goes to their manager for approval. The planner pauses until the manager decides, and books the flight and hotel only after approval. Before paying, it checks the flight and hotel prices again, and books neither if either rose by more than an allowed margin.

## Project layout

The project is a workspace with one integration and three agent libraries:

```
corporate-travel-planner/
├── travel_planner/          # The integration: HTTP API, planner agent, approvals and booking
├── destination_researcher/  # Library: DestinationResearcherAgent (Open-Meteo, GOV.UK travel advice)
├── logistics_coordinator/   # Library: LogisticsCoordinatorAgent (Duffel Flights and Stays)
└── policy_analyst/          # Library: PolicyAnalystAgent (travel policy, Frankfurter exchange rates)
```

Each library's `README.md` describes its agent, and the functions it shares with the other packages.

## Prerequisites

- An OpenAI API key. The agents use `gpt-6-luna`.
- A Duffel access token. A test-mode token (`duffel_test_...`) is free and books nothing real. Create one in the [Duffel dashboard](https://app.duffel.com).

The weather, travel advice and exchange rate APIs need no keys.

## Configuration

Provide the configuration through a `Config.toml` file in the `travel_planner` directory:

```toml
openAiApiKey = "<OPENAI_API_KEY>"
# How much a price may rise between approval and booking before the booking stops. Defaults to 2.
priceTolerancePercent = 2

[wso2.logistics_coordinator]
duffelAccessToken = "<DUFFEL_ACCESS_TOKEN>"
# Duffel's test mode only stocks hotels at one test location, so hotel searches go there.
# Set to false with a live token to search at the destination. Defaults to true.
useDuffelTestHotels = true
```

The sample has two employees: `E1001`, a staff-grade traveler, and `M2001`, their manager. The `x-employee-id` header identifies the caller. This stands in for authentication; in production, validate a token instead.

## Usage Instructions

1. Run the integration.
2. As the employee, ask for a trip:

   ```bash
   curl -X POST http://localhost:9090/travel/chat \
     -H "Content-Type: application/json" -H "x-employee-id: E1001" \
     -d '{"sessionId": "trip-1", "message": "I need to go to Tokyo for a customer workshop, 2026-12-15 to 2026-12-19. Please find flights and a hotel."}'
   ```

   The agents take about a minute. The reply describes the flight, the hotel, the weather, the FCDO advice, the USD total and the policy result, and gives a proposal ID such as `TRIP-3D9001A6`. With a test-mode token, the hotel is a Duffel test property, and the planner says so.

3. Confirm the booking in the same session:

   ```bash
   curl -X POST http://localhost:9090/travel/chat \
     -H "Content-Type: application/json" -H "x-employee-id: E1001" \
     -d '{"sessionId": "trip-1", "message": "Yes, submit it for approval."}'
   ```

   The response has the status `AWAITING_APPROVAL`, and lists the pending approval with its `approvalId` and the full proposal. Nothing is booked yet.

4. As the manager, list the bookings waiting for a decision:

   ```bash
   curl http://localhost:9090/travel/approvals -H "x-employee-id: M2001"
   ```

5. Approve the booking:

   ```bash
   curl -X POST http://localhost:9090/travel/approvals/<approvalId> \
     -H "Content-Type: application/json" -H "x-employee-id: M2001" \
     -d '{"outcome": "APPROVE"}'
   ```

   The planner resumes, books the flight and hotel, and replies with the booking references. To reject instead, send `{"outcome": "REJECT", "reason": "..."}`; the planner tells the employee why, and nothing is booked. Only the traveler's manager can decide: any other caller gets `403 Forbidden`.

6. Read the proposal, its booking status and its audit trail, as the traveler or the manager:

   ```bash
   curl http://localhost:9090/travel/proposals/<proposalId> -H "x-employee-id: E1001"
   ```

## How It Works

- The planner and its specialists are separate agents. The specialists are agent definitions in library packages, which the planner calls as tools.
- The policy checks are ordinary code in `policy_analyst`. The agents explain the result, but never decide it. The planner creates a proposal only from flight offers and hotel rates that a search actually returned, so a model cannot invent one. The model also chooses which proposal to submit, so the integration checks that the proposal belongs to the traveler before their manager sees it.
- Booking is the planner's `bookTrip` tool, marked `@ai:AgentTool {requiresApproval: true}`. When the planner calls it, the run pauses and the HTTP API returns the pending approval. The manager's decision resumes the run.
- A booking runs once. Deciding an approval a second time returns `404 Not Found`, and the planner refuses to book a proposal that is already booked. Orders and bookings are never retried automatically, so a network retry cannot book twice. If Duffel's answer to an order or booking is lost, for example after a timeout, the proposal is marked `NEEDS_REVIEW`: check the Duffel dashboard before booking again.
- The employee directory and the travel policy are stand-ins for an HR system and a policy service. Proposals, approvals and conversation history are kept in memory, so they last only while the integration runs.
