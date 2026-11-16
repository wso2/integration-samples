# Product and pricing assistant

This sample coordinates two specialist agents to answer product and pricing questions. A product specialist retrieves catalog evidence, and a pricing specialist calculates a monthly quote from a sample price list.

Use this sample to explore agent delegation with a shared runtime context. It recommends plans and quotes prices without creating subscriptions or taking payments.

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
3. Ask for a plan and a quote:

   ```bash
   curl -X POST http://localhost:9090/product-pricing-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"pricing-1","message":"We need cloud meeting recording for 25 users. Which is the lowest-tier suitable plan, and what is the total monthly price?"}'
   ```

   The catalog identifies Business as the lowest-tier plan with cloud meeting recording. The sample price is `12.00` per user per month, so 25 users cost `300.00` per month. The response includes supporting catalog evidence.

4. Ask about a feature outside the catalog:

   ```bash
   curl -X POST http://localhost:9090/product-pricing-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"pricing-2","message":"Which plan includes a built-in payroll system, and what does it cost for 25 users?"}'
   ```

   No catalog plan lists this feature. The instructions require the coordinator to report the gap rather than invent a plan or price.

Reuse a `sessionId` for follow-up messages. A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Test the tools

Run `bal test --offline` from this directory. The tests cover price lookup, quote calculation, unknown plans, and rejection of nonpositive user counts.

`tests/Config.toml` contains a loopback URL and an unused placeholder token. The tests initialize providers but do not call model or embedding services. They do not test catalog retrieval, delegation, or chat recommendations.

## How it works

- `productPricingCoordinatorAgent` delegates feature questions to `productSpecialistAgentTool` and quote requests to `pricingSpecialistAgentTool`.
- Both delegation tools forward `ai:Context` to the specialist's `run` call. The coordinator's instructions require separate session IDs for independent specialist conversations.
- `productSpecialistAgent` calls `retrieveProductCatalog` to retrieve evidence from an in-memory vector knowledge base.
- `pricingSpecialistAgent` uses `lookupPlanPrice` and `calculatePlanQuote` to calculate prices from `samplePriceList`. The quote tool requires a positive user count.
- `main.bal` loads `resources/product-catalog.md` at startup. This step calls the embedding provider.
- `automation.bal` exposes `POST /product-pricing-assistant/chat` through the AI listener.

The catalog and prices are fictional. Prices have no assigned currency, and the calculation excludes taxes and discounts. The model chooses the plan name and user count passed to tools. Validate those values and add authentication before using real catalog or billing systems.
