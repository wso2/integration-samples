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

3. Check the claim. The agent pays it without asking anyone, and answers with a one-line summary:

   ```bash
   curl http://localhost:9090/claims/<claimId>
   ```

4. Submit a claim above the approval limit:

   ```bash
   curl -X POST http://localhost:9090/claims \
     -H "Content-Type: application/json" \
     -d '{"employee": "bob", "description": "Conference ticket", "amount": 900}'
   ```

5. List the pending task as an approver. Only a caller with the approver role sees it:

   ```bash
   curl "http://localhost:8234/workflow/human-tasks?parentWorkflowId=<claimId>" \
     -H "x-user-roles: MANAGER"
   ```

6. Approve or reject the claim with the `taskId` from the previous response:

   ```bash
   curl -X POST http://localhost:8234/workflow/human-tasks/<taskId>/complete \
     -H "x-user-id: jane" -H "x-user-roles: MANAGER" \
     -H "Content-Type: application/json" \
     -d '{"result": {"approved": true, "comment": "Budgeted for this quarter"}}'
   ```

7. Submit a small claim that is not a business expense, such as `{"employee": "cal", "description": "Birthday gift for my wife", "amount": 80}`. The agent sends it to the approver too, whatever the amount.
8. Check the claim again. The agent's summary says whether the claim was paid or rejected, and that a person approved it.

## How It Works

- `claimAgent` is a `workflow:DurableAgent`. Each claim is one durable run of the agent: `POST /claims` starts it with `run`, and `GET /claims/{claimId}` reads its summary with `getResult`.
- The agent uses the default WSO2 model provider and these activities as its tools:
  - **recordClaim**: Records the claim
  - **checkPolicy**: Says whether the claim needs approval. It takes the amount and the agent's own judgment of whether the description is a business expense, so that judgment is recorded in the run's history. A claim that is not a business expense, or is above `approvalLimit`, needs approval
  - **payClaim**: Pays the claim
  - **notifyRejection**: Tells the employee that the claim was rejected
- The activities only log in this sample, so replace them with your own systems.
- The `approveClaim` human task is also a tool. The agent calls it only when it decides that the claim needs approval. The agent then pauses durably until a person with the `approverRole` role completes the task, and continues with the decision.
- Importing `ballerina/workflow.management.rest` serves the management REST API, which a task inbox uses to list and complete tasks. In production, enable JWT or OAuth2 authentication so that the caller's roles come from a verified token.
