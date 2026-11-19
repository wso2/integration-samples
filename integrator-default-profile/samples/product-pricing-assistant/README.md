# Product and pricing assistant

This sample coordinates two specialist agents to answer product and pricing questions. A product specialist retrieves catalog evidence, and a pricing specialist calculates a monthly quote from live Stripe prices.

Use this sample to explore agent delegation with a shared runtime context. It recommends plans and quotes prices, and it only reads from Stripe: it doesn't create customers or subscriptions, or take payments.

## Prerequisites

- Ballerina `2201.14.1` and WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Stripe account. We recommend test mode.
- One Stripe product for each catalog plan, named exactly `Starter`, `Pro`, `Business`, and `Enterprise`. Give each product an active, monthly recurring, per-unit price in a two-decimal currency such as USD, for example `5.00`, `9.00`, `12.00`, and `20.00`.

## Configuration

Create `Config.toml` in the sample directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Stripe key yourself:

```toml
stripeSecretKey = "STRIPE_SECRET_KEY"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `STRIPE_SECRET_KEY`: your Stripe secret key, or a restricted key with read access to products and prices.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model and the embedding provider use them.

Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Ask for a plan and a quote:

   ```bash
   curl -X POST http://localhost:9090/product-pricing-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"pricing-1","message":"We need cloud meeting recording for 25 users. Which is the lowest-tier suitable plan, and what is the total monthly price?"}'
   ```

   The catalog identifies Business as the lowest-tier plan with cloud meeting recording. With a Business price of `12.00` per user per month, 25 users cost `300.00` per month. The response includes supporting catalog evidence.

4. Ask about a feature outside the catalog:

   ```bash
   curl -X POST http://localhost:9090/product-pricing-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"pricing-2","message":"Which plan includes a built-in payroll system, and what does it cost for 25 users?"}'
   ```

   No catalog plan lists this feature. The instructions require the coordinator to report the gap rather than invent a plan or price.

Reuse a `sessionId` for follow-up messages. A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `productPricingCoordinatorAgent`

Answers product-and-price questions by delegating to the two specialists in the following sections and combining their results into one answer. It never states product facts or prices itself. This is the agent the HTTP service calls.

- **Query:** a feature question, optionally with a plan and user count to price, for example `We need cloud meeting recording for 25 users. Which is the lowest-tier suitable plan, and what is the total monthly price?`.
- **Response:** a `string` with the recommended plan, the supporting catalog evidence, and the calculated price when one was requested.
- **Tools:** `productSpecialistAgentTool`, `pricingSpecialistAgentTool`.

### `productSpecialistAgent`

Finds which plans support a requested feature and recommends the lowest-tier plan that does, quoting the catalog passage as evidence. It reports a gap when no plan supports the feature.

- **Query:** a product or feature question.
- **Response:** a `string` with the recommended plan and the supporting evidence.
- **Tools:** `retrieveProductCatalog`.

### `pricingSpecialistAgent`

Calculates a monthly quote from the plan's live Stripe price. It never invents a price and reports plans without a Stripe product or active price.

- **Query:** a plan name and a user count.
- **Response:** a `string` with the price per user per month and the total monthly price.
- **Tools:** `lookupPlanPrice`, `calculatePlanQuote`.

All three agents take a `model` initialization parameter, the model provider the agent uses.

## How it works

- `productPricingCoordinatorAgent` delegates feature questions to `productSpecialistAgentTool` and quote requests to `pricingSpecialistAgentTool`.
- Both delegation tools forward `ai:Context` to the specialist's `run` call. The coordinator's instructions require separate session IDs for independent specialist conversations.
- `productSpecialistAgent` calls `retrieveProductCatalog` to retrieve evidence from an in-memory vector knowledge base.
- `lookupPlanPrice` searches Stripe for a product with the plan's name, reads its first active recurring price, and converts `unit_amount` from cents.
- `calculatePlanQuote` multiplies that price by the user count. It requires a positive user count.
- `connections.bal` creates the Stripe client and the knowledge base.
- `main.bal` loads `resources/product-catalog.md` at startup. This step calls the embedding provider.
- `automation.bal` exposes `POST /product-pricing-assistant/chat` through the AI listener.

## Limitations

- `lookupPlanPrice` uses the first active recurring price that Stripe returns and doesn't check its interval. Give each product a single active price, and make it monthly.
- The price conversion divides by 100, so zero-decimal currencies such as JPY give wrong prices.
- Tiered and volume prices have no `unit_amount`, so the pricing specialist reports them as unavailable.
- Stripe can take up to a minute to include a new or renamed product in search results.

The catalog is fictional, and the calculation excludes taxes and discounts. The model chooses the plan name and user count passed to tools. Validate those values and add authentication before you connect a real billing account.
