# Customer returns assistant

This sample recommends an exchange, refund, or manual review for a faulty item. It combines retrieval-augmented generation (RAG) over a return policy with tools that check sample orders, return eligibility, and replacement stock.

The agent recommends a resolution only. It does not create returns, process refunds, or change inventory.

## Prerequisites

- Ballerina `2201.14.1` and WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.

## Configuration

The provider command adds settings to `Config.toml` in the sample directory:

```toml
[ballerina.ai.wso2ProviderConfig]
serviceUrl = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

Use the service URL and access token supplied by the provider command, not the placeholders. The model and embedding provider use this configuration. Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Ask about the faulty headset:

   ```bash
   curl -X POST http://localhost:9090/customer-returns-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"returns-1","message":"My Wireless Headset from order ORD-1042 is faulty. What can I do?"}'
   ```

   This order arrived 12 days ago and has five replacement units in stock. The sample rules support an exchange within the 30-day return window.

4. Ask about an order outside the return window:

   ```bash
   curl -X POST http://localhost:9090/customer-returns-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"returns-2","message":"My Bluetooth Speaker from order ORD-2087 is defective. Can I return it?"}'
   ```

   This order arrived 45 days ago. The sample rules require manual review.

Reuse a `sessionId` for follow-up messages. A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Test the tools

Run `bal test --offline` from this directory. The tests cover order lookup, stock lookup, the return-window boundary, and rejection of negative delivery ages.

`tests/Config.toml` contains a loopback URL and an unused placeholder token. The tests initialize providers but do not call model or embedding services. They do not test policy retrieval or chat recommendations.

## How it works

- `agents.bal` defines the agent's instructions and four tools.
- `functions.bal` provides `lookupOrder`, `checkReturnWindowEligibility`, `checkReplacementStock`, and `retrieveReturnPolicy`. The eligibility tool rejects negative delivery ages.
- `main.bal` loads `resources/return-policy.md` into an in-memory vector knowledge base at startup. This step calls the embedding provider.
- `automation.bal` exposes `POST /customer-returns-assistant/chat` through the AI listener.

The order records and stock counts are fictional, read-only data. The model chooses tool arguments and interprets the policy; its recommendation is not an authorization check. Add authentication, order ownership checks, and server-side business rules before connecting real systems.
