# Inbound Sales Agent

## Description

An AI agent that handles "talk to sales" emails for the fictional product Stratus. It answers
product questions from a small RAG knowledge base, looks up or creates Salesforce Leads/Contacts,
and flags anything needing a human (pricing, contracts, legal/security review, meetings) as a
Salesforce Task for a sales rep.

## Prerequisites

- WSO2 Integrator, with the default WSO2 model provider configured. In WSO2 Integrator, run the
  **Configure default WSO2 model provider** command. It adds the provider's settings to
  `Config.toml`. The agent and the knowledge base's embeddings both use this provider.
- A Gmail account to receive sales inquiries, with OAuth credentials for the Gmail API (scopes:
  `gmail.modify` and `gmail.send` at minimum) and a refresh token.
- A Salesforce org with an external client app (or connected app) that has the OAuth client
  credentials flow enabled and a run-as user assigned.

### Gmail labels

- **`Inquiry`**: apply this label (manually, via a Gmail filter, or however inbound sales
  emails reach the inbox) to any email you want this automation to pick up.
- **`sales-processed`**: created automatically by the automation the first time it processes a
  message. You don't need to create it yourself.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
gmailClientId = "<GMAIL_CLIENT_ID>"
gmailClientSecret = "<GMAIL_CLIENT_SECRET>"
gmailRefreshToken = "<GMAIL_REFRESH_TOKEN>"

# Your Salesforce instance URL, e.g. https://<your-domain>.my.salesforce.com
salesforceBaseUrl = "<SALESFORCE_BASE_URL>"
salesforceClientId = "<SALESFORCE_CLIENT_ID>"
salesforceClientSecret = "<SALESFORCE_CLIENT_SECRET>"
# Your org's My Domain token endpoint. The client credentials flow does not work with
# login.salesforce.com.
salesforceTokenUrl = "https://<your-domain>.my.salesforce.com/services/oauth2/token"

# Optional. Defaults to "label:Inquiry is:unread".
gmailSearchQuery = "label:Inquiry is:unread"
# Optional. Polling interval in seconds. Defaults to 120.
pollingIntervalSeconds = 120

# Added by the "Configure default WSO2 model provider" command.
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

## Usage Instructions

1. Run the integration. It loads the product docs into the knowledge base and then polls Gmail
   every `pollingIntervalSeconds`.
2. From another email address, send the Gmail account an email with a subject like "Talk to
   sales about Stratus" and a body such as:

   > Hi, I'm James Perera, engineering manager at SprocketSoft. We're a 40-person engineering
   > team currently using spreadsheets to track projects and want to see if Stratus could replace
   > that. Can Stratus update tasks automatically from our Git pull requests? Can we keep our data
   > in the EU? Also, does Stratus support SSO with our identity provider?

3. Apply the `Inquiry` label to that email (or set up a Gmail filter that applies it
   automatically based on sender/subject), and leave it unread.
4. Wait for the next poll (up to `pollingIntervalSeconds`).
5. Check that:
   - A reply appears in the same thread answering the pull request, EU data residency, and SSO
     questions from the docs.
   - A new Lead appears in Salesforce for the sender, with a dated conversation summary in its
     Description. If the sender already exists as an open Lead or a Contact, that record's
     Description gets the summary instead and no duplicate Lead is created.
   - The original email is marked read and labeled `sales-processed`.
6. To test the follow-up/escalation path, send a message asking about pricing or requesting a
   call — the reply should say a sales rep will follow up, and a high-priority Salesforce Task
   should be created against the Lead/Contact instead of an answer being given.

## How It Works

1. **Automation** (`automation.bal`): every `pollingIntervalSeconds` (default 120 seconds), a
   scheduled job searches Gmail for messages matching `gmailSearchQuery` (default
   `label:Inquiry is:unread`), across all result pages. Messages already labeled `sales-processed`
   are always excluded, so each message is handled only once. Messages sent from the mailbox
   itself, including the agent's own replies, are also excluded. If a poll is still running when the
   next one is due, the next one is skipped, and the following poll picks up any remaining
   messages.
2. For each match, it loads the **full Gmail thread** (so earlier messages in the conversation are
   included), skips messages from no-reply/automated senders, and runs the **salesAssistantAgent**
   with the sender's name/email, subject, thread id, and ordered thread messages. The agent has no
   memory between runs, so each email is handled on its own with its full thread as context.
3. The agent answers product questions using only the `searchProductDocs` tool (backed by an
   in-memory vector knowledge base ingested from `docs/` on startup), looks up the sender in
   Salesforce via `findLeadOrContact` (open Leads first, then Contacts), and creates a Lead,
   updates the existing Lead or Contact, or creates a follow-up Task as needed.
4. **The agent itself decides whether to reply.** When a reply is warranted, it composes a
   plain-text email and sends it by calling the `sendEmailReply` tool, which replies in the
   **same Gmail thread** (correct `threadId`, `In-Reply-To`/`References` headers, `Re: <subject>`).
   It skips replying for things like auto-generated messages, threads with no new question, or
   spam/unrelated messages.
5. Once the agent run finishes — whether or not it sent a reply — the original message is marked
   read and labeled `sales-processed`. Messages from no-reply/automated senders are marked the
   same way without running the agent.
6. If anything fails while processing a message, the error is logged and the message is left
   unread so it is retried on the next run.

### Product docs (RAG)

Sample product docs for the fictional product Stratus live in `docs/` as PDFs:
- `features-overview.pdf`
- `integrations.pdf`
- `security-and-compliance.pdf`
- `deployment-options.pdf`
- `faq.pdf`

These are loaded into an in-memory vector knowledge base on startup (see `main.bal`), so the
sample runs without any external vector database. Pricing is intentionally not included — the
agent is instructed to hand off pricing questions to a sales rep rather than answer them.

To use your own product docs, replace the files in `docs/`. The loader supports PDF, DOCX, PPTX,
Markdown, and HTML files.
