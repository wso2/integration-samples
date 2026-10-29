# Claim Approval Workflow

## Description

An expense claim approval process built as a durable workflow in WSO2 Integrator. An employee submits a claim over HTTP. The workflow records the claim and pauses on a human task until an approver decides on it, for minutes or for days. It then pays the claim or notifies the employee that it was rejected. The role that can decide on the claim is configurable.

## Prerequisites

- WSO2 Integrator.
- To keep running workflows across restarts, a Temporal server, such as one started with `temporal server start-dev`. To try the sample without one, use the in-memory mode shown below.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
# The role that can approve claims. Defaults to MANAGER.
approverRole = "MANAGER"

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
2. Submit a claim. The response carries the claim ID, which is also the workflow ID:

   ```bash
   curl -X POST http://localhost:9090/claims \
     -H "Content-Type: application/json" \
     -d '{"employee": "ann", "description": "Client dinner", "amount": 120.50}'
   ```

   The amount must be positive. Otherwise, the request fails with `400 Bad Request`.

3. Check the claim. While it waits for a decision, its status is `IN_REVIEW`:

   ```bash
   curl http://localhost:9090/claims/<claimId>
   ```

   ```json
   {"claimId": "<claimId>", "status": "IN_REVIEW"}
   ```

4. List the pending task as an approver. Only a caller with the approver role sees it:

   ```bash
   curl "http://localhost:8234/workflow/human-tasks?parentWorkflowId=<claimId>" \
     -H "x-user-roles: MANAGER"
   ```

5. Decide on the claim with the `taskId` from the previous response. To approve it, complete the task with `approved` set to `true`:

   ```bash
   curl -X POST http://localhost:8234/workflow/human-tasks/<taskId>/complete \
     -H "x-user-id: jane" -H "x-user-roles: MANAGER" \
     -H "Content-Type: application/json" \
     -d '{"result": {"approved": true, "comment": "Approved"}}'
   ```

   To reject it, complete the task the same way with `approved` set to `false`:

   ```bash
   curl -X POST http://localhost:8234/workflow/human-tasks/<taskId>/complete \
     -H "x-user-id: jane" -H "x-user-roles: MANAGER" \
     -H "Content-Type: application/json" \
     -d '{"result": {"approved": false, "comment": "Missing the receipt"}}'
   ```

   A rejection is a decision, so it is a completed task. The task's `/fail` route is for a task that cannot be decided. It fails the whole workflow, and the claim's status becomes `FAILED`.

6. Check the claim again. It now shows the decision and the approver's comment:

   ```json
   {"claimId": "<claimId>", "status": "APPROVED", "comment": "Approved"}
   ```

   ```json
   {"claimId": "<claimId>", "status": "REJECTED", "comment": "Missing the receipt"}
   ```

## How It Works

- `POST /claims` starts the `processClaim` workflow with `workflow:run`. `GET /claims/{claimId}` reads its result with `workflow:getResult`, and reports `IN_REVIEW` while it runs, `FAILED` if it failed, and `404 Not Found` for an unknown ID.
- The workflow calls three activities, the steps that act on other systems: `recordClaim`, `payClaim` and `notifyRejection`. In this sample they only log, so replace them with your own systems.
- `awaitHumanTask` creates the `approveClaim` task for the role in `approverRole` and pauses the workflow durably until the task is completed. The task carries the claim details for the approver to see.
- Importing `ballerina/workflow.management.rest` serves the management REST API, which a task inbox uses to list and complete tasks. In production, enable JWT or OAuth2 authentication so that the caller's roles come from a verified token.
