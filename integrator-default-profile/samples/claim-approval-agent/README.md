# Claim Approval Agent

## Description

An expense claim approval process run by a durable AI agent in WSO2 Integrator. An employee submits a claim over HTTP, and the agent handles it from start to finish. It judges whether the claim reads as a business expense, and checks it against the expense policy. A claim above the approval limit, or one that is not a business expense, such as a personal gift, goes to an approver through a human task. The agent pauses durably until the approver decides, and then pays or rejects the claim. Every other claim is paid without waiting for anyone. The approver role and the approval limit are configurable.

## Prerequisites

- WSO2 Integrator, with the default WSO2 model provider configured. In WSO2 Integrator, run the **Configure default WSO2 model provider** command. It adds the provider's settings to `Config.toml`.
- To keep running agents across restarts, a Temporal server, such as one started with `temporal server start-dev`. To try the sample without one, use the in-memory mode shown below.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
# The role that can approve claims. Defaults to MANAGER.
approverRole = "MANAGER"
# Claims above this amount need an approver. Defaults to 500.
approvalLimit = 500

# Added by the "Configure default WSO2 model provider" command.
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"

# Runs the workflow engine inside the integration, so no server is needed. State lasts only
# while the integration runs. Remove this section to connect to a Temporal server on localhost:7233.
[ballerina.workflow]
mode = "IN_MEMORY"

# The management REST API serves the human tasks on port 8234. Authentication is off for
# this sample, so any caller can set its roles with the `x-user-roles` header.
# Do not run it this way in production.
[ballerina.workflow.management.rest]
enableBasicAuth = false
```

## Usage Instructions

1. Run the integration.
2. Submit a claim within the approval limit. The response carries the claim ID, which is also the agent's workflow ID:

   ```bash
   curl -X POST http://localhost:9090/claims \
     -H "Content-Type: application/json" \
     -d '{"employee": "ann", "description": "Taxi to the airport", "amount": 45}'
   ```

   The amount must be positive. Otherwise, the request fails with `400 Bad Request`.

3. Check the claim:

   ```bash
   curl http://localhost:9090/claims/<claimId>
   ```

   The agent takes a few model calls to decide, so the first response is usually `IN_REVIEW`. Repeat the request until the response carries the agent's `summary`. The agent pays this claim without asking anyone:

   ```json
   {"claimId": "<claimId>", "status": "APPROVED", "comment": "", "summary": "The claim was paid without requiring approval."}
   ```

4. Submit a claim above the approval limit, and note its claim ID:

   ```bash
   curl -X POST http://localhost:9090/claims \
     -H "Content-Type: application/json" \
     -d '{"employee": "bob", "description": "Conference ticket", "amount": 900}'
   ```

5. List the pending task as an approver. Only a caller with the approver role sees it. The task appears once the agent has checked the claim, so repeat the request if the list is empty:

   ```bash
   curl "http://localhost:8234/workflow/human-tasks?parentWorkflowId=<claimId>" \
     -H "x-user-roles: MANAGER"
   ```

6. Decide on the claim with the `taskId` from the previous response. To approve it, complete the task with `approved` set to `true`:

   ```bash
   curl -X POST http://localhost:8234/workflow/human-tasks/<taskId>/complete \
     -H "x-user-id: jane" -H "x-user-roles: MANAGER" \
     -H "Content-Type: application/json" \
     -d '{"result": {"approved": true, "comment": "Budgeted for this quarter"}}'
   ```

   To reject it, complete the task the same way with `approved` set to `false` and a comment that says why.

7. Check the claim from step 4 again, and repeat until the response carries a `summary`. The status is `APPROVED` or `REJECTED`, matching your decision, with your comment:

   ```json
   {"claimId": "<claimId>", "status": "APPROVED", "comment": "Budgeted for this quarter", "summary": "The claim was paid, and it was approved by Jane."}
   ```

8. Submit a small claim that is not a business expense, and note its claim ID:

   ```bash
   curl -X POST http://localhost:9090/claims \
     -H "Content-Type: application/json" \
     -d '{"employee": "cal", "description": "Birthday gift for my wife", "amount": 80}'
   ```

   The amount is within the limit, but the agent still sends the claim to the approver. Repeat steps 5 to 7 with this claim ID to decide on it.

## How It Works

- `claimAgent` is a `workflow:DurableAgent`. `POST /claims` records the claim and starts one durable run of the agent for it with `runWithId`, using the claim ID as the run's ID. `GET /claims/{claimId}` reads the recorded claim's status and the agent's summary with `getResult`. It reports `FAILED` if the run failed, and `404 Not Found` for an unknown ID.
- The agent uses the default WSO2 model provider and these activities as its tools:
  - **checkPolicy**: Says whether the claim needs approval. It takes the agent's own judgment of whether the description is a business expense, so that judgment is recorded in the run's history. A claim that is not a business expense, or is above `approvalLimit`, needs approval.
  - **payClaim**: Pays the claim
  - **notifyRejection**: Tells the employee that the claim was rejected
- The activities take only the claim ID, and read the amount from the recorded claim. The model decides which step comes next, but never supplies an amount that is paid. In this sample, claims are kept in memory and the activities only log, so replace them with your own claims and payment systems.
- The `approveClaim` human task is also a tool. The agent calls it only when it decides that the claim needs approval. It then pauses durably until a person with the `approverRole` role completes the task, and continues with the decision. `taskInputType` fixes the shape of the task's input, so every task in the approver's inbox shows the same fields.
- The business-expense judgment is made by the model from text that the employee writes, so a description can argue its own case. Treat the judgment as a triage hint, not as a control. In a real deployment, keep a check that does not depend on it, such as reviewing a sample of the claims paid without approval, or a cap per employee.
- Importing `ballerina/workflow.management.rest` serves the management REST API, which a task inbox uses to list and complete tasks. In production, enable JWT or OAuth2 authentication so that the caller's roles come from a verified token.
