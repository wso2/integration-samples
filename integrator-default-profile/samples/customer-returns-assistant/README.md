# Customer returns assistant

This sample recommends an exchange, refund, or manual review for a faulty item. It reads orders and replacement stock from a Shopify store and applies a 30-day return policy that is part of the agent's instructions.

Every file in this sample comes from Choreo Agent Builder's forms: the agent, the Shopify connection and its configurables, six tools made from Shopify actions and standard library functions, and the Agent Chat entry point. You can build the same project in Agent Builder without writing code.

The agent recommends a resolution only. It reads from Shopify but does not create returns, process refunds, or change inventory.

## Prerequisites

- Ballerina `2201.14.2` and Choreo Agent Builder, or WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Shopify store, such as a development store, with at least one fulfilled order.
- A Shopify Admin API access token with the `read_orders` and `read_products` scopes. Since January 1, 2026, Shopify no longer lets you create custom apps in the Shopify admin, so create the app in the Shopify Dev Dashboard instead:
  1. In the [Dev Dashboard](https://dev.shopify.com/dashboard/), create an app.
  2. Create a version of the app, enter `read_orders,read_products` as its scopes, and release the version.
  3. Install the app on your store.
  4. In the app's settings, copy the client ID and client secret, and request an access token with the [client credentials grant](https://shopify.dev/docs/apps/build/authentication-authorization/client-credentials-grant).

  This token expires after 24 hours. The sample reads it once from `Config.toml`, so request a new token and restart the sample when it expires. An access token from a custom app that you created in the Shopify admin before 2026 also works and doesn't expire.

## Configuration

The sample is a workspace with one package, `customer_returns_assistant`. Create `Config.toml` in the `customer_returns_assistant` directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Shopify values yourself:

```toml
shopifyAccessToken = "SHOPIFY_ACCESS_TOKEN"
shopifyStoreServiceUrl = "https://STORE_NAME.myshopify.com"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `SHOPIFY_ACCESS_TOKEN`: the Admin API access token of your app.
- `STORE_NAME`: your store's subdomain. The connector adds the `/admin/api/...` path itself.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model uses them.

Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in Choreo Agent Builder or WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from the `customer_returns_assistant` directory.
3. Ask about a faulty item, using an order number from your store:

   ```bash
   curl -X POST http://localhost:9090/customer-returns-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"returns-1","message":"The headset from order #1042 is faulty. What can I do?"}'
   ```

   The agent finds order `#1042`, reads its shipped items, and identifies the headset. It works out how long ago the headset shipped and checks the stock of its variant. If the order has several items and the message doesn't name one, the agent asks which item is faulty. Within the 30-day return window, it recommends an exchange when a replacement is in stock and a refund when none is. After 30 days, or when it can't find the order, it recommends manual review.

Reuse a `sessionId` for follow-up messages. A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `customerReturnsAgent`

Recommends an exchange, a refund, or manual review for a faulty or defective item, and quotes the policy rule that supports the recommendation. It never creates a return or moves money.

- **Query:** a return request that includes a Shopify order number, for example `The headset from order #1042 is faulty. What can I do?`. The agent asks for the order number if it is missing.
- **Response:** a `string` with the recommendation, the reason, and the policy rule.
- **Tools:** `findOrder`, `getOrderDetails`, `checkReplacementStock`, `getCurrentTime`, `parseShipDate`, `secondsBetween`.
- **Model:** the default WSO2 model provider.

## How it works

All the code is in the `customer_returns_assistant` package:

- `agents.bal` defines the agent and its six tools. The instructions hold the return policy and the steps the agent follows, including which tool to call at each step.
- `config.bal` declares the `shopifyAccessToken` and `shopifyStoreServiceUrl` configurables.
- `connections.bal` creates the Shopify Admin client, `shopifyClient`.
- `main.bal` exposes `POST /customer-returns-assistant/chat` on `agentChatListener`, the shared listener on port `9090`.
- `automation.bal`, `data_mappings.bal`, `functions.bal`, and `types.bal` are empty files that Agent Builder creates with every project.

The tools wrap Shopify actions and standard library functions, so the model does the reasoning between them:

- `findOrder` calls the Shopify action that lists orders, filtered by order name (for example, `#1042`) and status. The agent uses status `any` so that closed orders are included.
- `getOrderDetails` gets one order by its ID, with its fulfillments. The agent uses only successful fulfillments; each one lists the shipped items with their variant IDs, and its creation date is the date they shipped.
- `checkReplacementStock` gets a product variant by its ID, including its inventory quantity.
- `getCurrentTime`, `parseShipDate`, and `secondsBetween` wrap `time:utcNow`, `time:utcFromString`, and `time:utcDiffSeconds`. The agent gets the seconds since the item shipped and compares them with 2,592,000 (30 days), so it doesn't calculate dates itself.

`bal build` reports three `undocumented return parameter` warnings, one for each time tool. Agent Builder copies the library function's parameter documentation but doesn't write a return line. The warnings don't affect the build.

## Limitations

- The model reads the Shopify responses and applies the policy itself. Its choice of item, its reading of the fulfillment data, and its recommendation can vary between runs and models.
- The sample policy counts the return window from the shipping date, because the Shopify fulfillment record doesn't carry a delivery date. A policy that counts from delivery needs the fulfillment's tracking events, which only some carriers report.
- Shopify returns orders older than 60 days only to apps with the `read_all_orders` scope. Without it, the agent reports an older order as not found and recommends manual review.

The model chooses tool arguments and interprets the policy; its recommendation is not an authorization check. Add authentication, order ownership checks, and server-side business rules before you expose this agent to customers.
