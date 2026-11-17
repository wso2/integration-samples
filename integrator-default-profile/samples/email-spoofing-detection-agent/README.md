# Email Spoofing Detection Agent

## Description

An AI agent that watches a Gmail inbox for spoofed and phishing emails. When a new email arrives, code reads its headers and collects the facts:

- the SPF, DKIM and DMARC results;
- the IP address the email was sent from;
- where that IP address is located and who owns it;
- the IP address's spam history and reputation.

The agent then judges those facts. It gives each email a spoofing risk of `LOW`, `MEDIUM` or `HIGH`, lists the evidence behind it, and logs the verdict. You can also ask for an analysis on demand over HTTP.

## Prerequisites

- WSO2 Agent Builder, signed in, so that the default WSO2 model provider is configured.
- A Google Cloud OAuth client with the Gmail API enabled, and a refresh token with the `https://www.googleapis.com/auth/gmail.readonly` scope for the mailbox to monitor. You can get the refresh token with the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground). For details, see the [Gmail API documentation](https://developers.google.com/gmail/api/guides).
- An API key from [IPQualityScore](https://www.ipqualityscore.com/). The free plan has a monthly credit limit. When it runs out, the IP reputation shows as `Unknown`, and the rest of the analysis still works.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
gmailClientId = "<GMAIL_CLIENT_ID>"
gmailClientSecret = "<GMAIL_CLIENT_SECRET>"
gmailRefreshToken = "<GMAIL_REFRESH_TOKEN>"
ipQualityScoreApiKey = "<IPQUALITYSCORE_API_KEY>"

# How often, in seconds, the poller checks for new emails. Defaults to 60.
pollIntervalSeconds = 60
# Gmail search query that selects the new emails to analyze. Defaults to "in:inbox".
pollQuery = "in:inbox"

# Added when you run the integration while signed in to WSO2 Agent Builder.
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

## Usage Instructions

1. Run the integration using the **Run** button. The poller starts checking the inbox for new emails. Emails that are already in the inbox when the integration starts are not analyzed.

   > **Note:** The access token of the default WSO2 model provider expires one hour after it is issued. The **Run** button gets a new token each time it starts the integration.
   >
   > After an hour, model calls fail with `401 Invalid Credentials`. The poller logs an error at each check, and the HTTP service returns `500 Internal Server Error`.
   >
   > To continue, stop the integration and click **Run** again. The **Restart** button on the debug toolbar keeps the expired token. To run the poller for longer, configure the agent to use a model provider with its own API key, such as OpenAI.

2. Send an email to the monitored mailbox. Within about a minute, the integration logs a verdict for it. A `LOW` risk is logged at the `INFO` level, and a `MEDIUM` or `HIGH` risk at the `WARN` level, with the full analysis:

   ```
   level=WARN message="HIGH spoofing risk: \"Verify your account\" from Example Bank <security@examp1e-bank.com>" analysis={...}
   ```

3. To analyze emails on demand, send a Gmail search query to the HTTP service:

   ```bash
   curl -X POST http://localhost:9090/email-header-analyzer/analyze \
     -H "Content-Type: application/json" \
     -d '{"query": "in:inbox newer_than:1d"}'
   ```

   The agent analyzes up to 10 matching emails. Each takes a few seconds, so keep the query narrow. The response has one entry per email:

   ```json
   {
     "emails": [
       {
         "messageId": "<MESSAGE_ID>",
         "subject": "Your order has shipped",
         "sender": "Example Store <orders@example.com>",
         "spf": "pass",
         "dkim": "pass",
         "dmarc": "pass",
         "initialIP": "<IP_ADDRESS>",
         "organization": "Example Email Service, Inc.",
         "country": "United States",
         "city": "San Francisco",
         "recentSpamActivity": "Not associated with recent spam",
         "ipSenderReputation": "Good",
         "spoofingRisk": "LOW",
         "reasons": ["SPF, DKIM, and DMARC all pass.", "The sending IP belongs to an email service provider and has no recent spam activity."]
       }
     ]
   }
   ```

4. To analyze specific emails, send their Gmail message IDs instead:

   ```bash
   curl -X POST http://localhost:9090/email-header-analyzer/analyze \
     -H "Content-Type: application/json" \
     -d '{"messageIds": ["<MESSAGE_ID>"]}'
   ```

## How It Works

- The integration has two triggers that call the same agent:
  - **Inbox poller** (`task:Service`): Checks Gmail every `pollIntervalSeconds` for emails that match `pollQuery` and arrived since the last check. It skips emails that it has already analyzed and logs the verdict for each new one.
  - **HTTP service** (`POST /email-header-analyzer/analyze`): Analyzes the emails that the request describes, and returns the report.
- The agent uses the default WSO2 model provider. It has these tools:
  - **listRecentEmails**: Finds the message IDs of up to 10 emails that match a Gmail search query.
  - **analyzeEmailHeadersTool**: Reads an email's headers through the Gmail API and returns the facts as fixed values. It wraps the `analyzeEmailHeaders` function in `functions.bal`, and works as follows:
    - It reads the SPF, DKIM, and DMARC results from the `Authentication-Results` header. If that header is missing, it falls back to the `Received-SPF`, `DKIM-Signature`, and DMARC headers.
    - It takes the originating IP address from the oldest `Received` header, ignoring loopback and private addresses. If that header records only a hop inside the sender's own network, it moves up to the next `Received` header.
    - It looks up the IP address's owner and location with [ip-api.com](https://ip-api.com/), and its fraud score with IPQualityScore. It maps the fraud score to a reputation: `Good` below 11, `OK` from 11, `Suspicious` from 50, `Poor` from 75, and `Bad` from 85.
- Code produces the facts, so the agent cannot invent them. The agent copies them into its answer unchanged and only decides `spoofingRisk` and `reasons`. It looks for these warning signs:
  - failing authentication;
  - a `Reply-To` or `Return-Path` domain that differs from the sender's;
  - a display name that claims a brand the address does not belong to;
  - a lookalike domain;
  - a poor IP reputation;
  - an IP owner that does not fit the sender.
- The agent keeps no memory between runs (`memory = ()`), so each check is analyzed on its own and a long-running poller does not build up chat history.
- The Gmail connector keeps only one value for each header name, which loses all but one `Received` header. So the tool reads the headers with an HTTP client for the Gmail API (`gmailApiClient`) instead.
