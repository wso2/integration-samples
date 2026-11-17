# IT Helpdesk Agent

## Description

An IT helpdesk agent that employees chat with in Google Chat or through the HTTP chat endpoint. It answers how-to questions from an IT knowledge base, unlocks locked accounts, grants app access, and raises incident tickets. Standard apps are granted straight away, and sensitive apps wait for the employee's manager to approve them. This sample shows how to build an AI agent in WSO2 Integrator that takes actions, not only answers questions.

## Prerequisites

- WSO2 Integrator, with the default WSO2 model provider configured. In WSO2 Integrator, run the **Configure default WSO2 model provider** command. It adds the provider's settings to `Config.toml`.

## Google Chat setup

1. Create a Google Cloud project and enable the Google Chat API.
2. On the Chat API's **Configuration** page, clear **Build this Chat app as a Workspace add-on**. Give the app a name and a description. Keep **Enable interactive features** on, and leave **Join spaces and group conversations** off.
3. Set the **HTTP endpoint URL** to your public HTTPS URL for port 8000, with no path. For example, run `ngrok http 8000` and use the URL it shows. Set the **Authentication audience** to **Project Number**.
4. Under **Visibility**, add your own email.
5. In the same project, create a service account and download its JSON key.

`googleChatProjectNumber` is the project number, not the project ID.

## Configuration

Provide the configuration through a `Config.toml` file in the project root. Add the two Google Chat lines above the `[ballerina.ai.wso2ProviderConfig]` table, because keys after a table belong to that table:

```toml
googleChatProjectNumber = "<PROJECT_NUMBER>"
serviceAccountKeyPath = "<PATH_TO_SERVICE_ACCOUNT_KEY_JSON>"

# Added by the "Configure default WSO2 model provider" command.
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

Keep the service account key file outside the project.

## Usage Instructions

1. Run the integration. The sample data is kept in memory, so restart the integration to start again from step 2.
2. Ask a how-to question:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s1", "message": "How do I connect to the VPN?"}'
   ```

   The agent answers from the knowledge base. If no article covers a question, it says so and offers to raise a ticket.

3. Tell the agent that an account is locked:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s2", "message": "I am david.lee@acme.com and my account is locked."}'
   ```

   The agent asks for the employee ID.

4. Send the employee ID in the same session:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s2", "message": "My employee ID is E1004."}'
   ```

   The agent unlocks the account and sends a password reset link.

5. Ask for a standard app. Jira is granted straight away:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s3", "message": "I am carol.davis@acme.com. Please give me access to Jira."}'
   ```

6. Ask for a sensitive app in the same session:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s3", "message": "I also need access to the AWS console."}'
   ```

   The agent replies with a request ID, such as `AR-1001`. The request waits for the manager.

7. Approve the request as the employee's manager:

   ```bash
   curl -X POST http://localhost:9090/approvals/requests/AR-1001/decision \
     -H "Content-Type: application/json" \
     -d '{"decision": "approve", "managerEmail": "grace.hall@acme.com", "comment": "Approved for the new project."}'
   ```

   To reject the request instead, set `decision` to `reject`.

8. Ask the agent for the request's status in the same session as step 6:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s3", "message": "What is the status of request AR-1001?"}'
   ```

   The agent replies that the request was approved.

9. Report a problem that the agent cannot solve:

   ```bash
   curl -X POST http://localhost:9090/helpdesk/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "s4", "message": "I am alice.johnson@acme.com. My laptop screen flickers, even after a restart and a graphics driver update."}'
   ```

   The agent raises an incident ticket and replies with its ID. Ask "Show me all my tickets" in the same session to list them.

10. To use Google Chat, send the same messages as direct messages to the Chat app. Approving a request stays a curl call, as in step 7.

## How It Works

- The agent uses the default WSO2 model provider, with an in-memory short-term memory that keeps the last 20 messages for each session.
- It implements eight agent tools:
  - **searchKnowledgeBase**: Searches eight IT articles, which are loaded at startup with the default WSO2 embedding provider
  - **lookupEmployee**: Looks up an employee's name, department, account status and apps by email
  - **unlockAccountAndSendReset**: Checks the employee ID, then unlocks the account and sends a password reset link
  - **requestAppAccess**: Grants a standard app, or creates an access request for a sensitive app (Salesforce, AWS console, Payroll)
  - **getAccessRequestStatus**: Returns the status of an access request
  - **createIncidentTicket**: Raises an incident ticket with a category, a priority and a summary
  - **getTicketStatus**: Returns the status of a ticket
  - **listEmployeeTickets**: Lists the employee's tickets
- The unlock tool checks the employee ID itself, so the model never sees the ID on record. After three wrong IDs within 15 minutes, it blocks the check for that employee for 15 minutes.
- Requests reach the integration through two services on the default listener:
  - **Chat service** (`/helpdesk/chat`): the agent's HTTP chat endpoint
  - **Approval service** (`/approvals`): managers decide access requests here. Only the employee's manager can decide a request, and only once.
- The Google Chat trigger listens on port 8000. It checks that each request comes from Google, acknowledges each message at once, and then posts the agent's reply. It is for direct messages only, because the conversation memory is kept per Google Chat space.
- Employees can see only their own tickets and access requests.
- In this sample, the employee directory (five employees, in `functions.bal`), access requests and tickets are kept in memory, so replace them with your own systems, such as Microsoft Entra ID and ServiceNow.
- The agent trusts the email that the employee gives, and the employee ID stands in for real identity verification. The approval service trusts the `managerEmail` in the request. Anyone who knows an email can also trigger that employee's 15-minute block. In production, take both identities from a verified sign-in, and put authentication in front of both services. Expose only port 8000 publicly, because port 9090 serves the HTTP chat and the approval service without authentication. A real deployment would take the employee from the Google Chat sender instead of asking for an email.
