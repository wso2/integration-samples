# Customer returns assistant

This sample recommends an exchange, refund, or manual review for a faulty item. It combines retrieval-augmented generation (RAG) over a return policy with tools that read orders and replacement stock from a Shopify store and check the return window.

The agent recommends a resolution only. It reads from Shopify but does not create returns, process refunds, or change inventory.

## Prerequisites

- Ballerina `2201.14.1` and WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Shopify store, such as a development store, with at least one fulfilled order.
- A Shopify Admin API access token with the `read_orders` and `read_products` scopes. To create one, create a custom app in the Shopify admin and install it on the store.

## Configuration

Create `Config.toml` in the sample directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Shopify values yourself:

```toml
shopifyAccessToken = "SHOPIFY_ACCESS_TOKEN"
shopifyStoreServiceUrl = "https://STORE_NAME.myshopify.com"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `SHOPIFY_ACCESS_TOKEN`: the Admin API access token of your custom app.
- `STORE_NAME`: your store's subdomain. The connector adds the `/admin/api/...` path itself.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model and the embedding provider use them.

Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Ask about a faulty item, using an order number from your store:

   ```bash
   curl -X POST http://localhost:9090/customer-returns-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"returns-1","message":"The headset from order #1042 is faulty. What can I do?"}'
   ```

   The agent looks up order `#1042`, counts the days since its first fulfillment, and checks the stock of the ordered variant. Within the 30-day return window, it recommends an exchange when a replacement is in stock and a refund when none is. After 30 days, or when it can't find the order, it recommends manual review.

Reuse a `sessionId` for follow-up messages. A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `customerReturnsAgent`

Recommends an exchange, a refund, or manual review for a faulty or defective item, and cites the return policy passage that supports the recommendation. It never creates a return or moves money.

- **Query:** a return request that includes a Shopify order number, for example `The headset from order #1042 is faulty. What can I do?`. The agent asks for the order number if it is missing.
- **Response:** a `string` with the recommendation, the reason, and the policy passage.
- **Tools:** `lookupOrder`, `retrieveReturnPolicy`, `checkReturnWindowEligibility`, `checkReplacementStock`.
- **Initialization parameters:** `model`, the model provider the agent uses.

## How it works

- `agents.bal` defines the agent's instructions and four tools.
- `connections.bal` creates the Shopify Admin client and the in-memory vector knowledge base for the return policy.
- `lookupOrder` finds the order by its name (for example, `#1042`) and returns the first fulfilled line item, its variant ID, and the whole days since the first fulfillment.
- `checkReturnWindowEligibility` compares the delivery age with the 30-day return window. It rejects negative ages.
- `checkReplacementStock` reads the variant's inventory quantity from Shopify.
- `retrieveReturnPolicy` retrieves the three most relevant passages from `resources/return-policy.md`.
- `main.bal` loads the return policy into the knowledge base at startup. This step calls the embedding provider.
- `automation.bal` exposes `POST /customer-returns-assistant/chat` through the AI listener.

## Limitations

- The sample treats the fulfillment date as the delivery date. Shopify records when an order ships, not when it arrives.
- `lookupOrder` reads only the first fulfillment and its first line item. Orders with several items or several shipments need more logic.
- Shopify returns orders older than 60 days only to apps with the `read_all_orders` scope. Without it, the agent reports an older order as not found and recommends manual review.

The model chooses tool arguments and interprets the policy; its recommendation is not an authorization check. Add authentication, order ownership checks, and server-side business rules before you expose this agent to customers.
