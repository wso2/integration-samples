# Product and pricing assistant

This sample coordinates two specialist agents to answer product and pricing questions. A product specialist recommends a plan from the catalog in its instructions, and a pricing specialist calculates a monthly quote from live Stripe prices.

Every file in this sample comes from Choreo Agent Builder's forms: the three agents, the Stripe connection and its configurable, two tools made from Stripe actions, two tools that call the specialist agents, and the Agent Chat entry point. You can build the same project in Agent Builder without writing code.

The assistant recommends plans and quotes prices, and it only reads from Stripe. It doesn't create customers or subscriptions, or take payments.

## Prerequisites

- Ballerina `2201.14.2` and Choreo Agent Builder, or WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Stripe account. We recommend test mode.
- One Stripe product for each catalog plan, named exactly `Starter`, `Pro`, `Business`, and `Enterprise`. Give each product an active, monthly recurring, per-unit price in a two-decimal currency such as USD, for example `5.00`, `9.00`, `12.00`, and `20.00`.

## Configuration

The sample is a workspace with one package, `product_pricing_assistant`. Create `Config.toml` in the `product_pricing_assistant` directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Stripe key yourself, above that table:

```toml
stripeSecretKey = "STRIPE_SECRET_KEY"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `STRIPE_SECRET_KEY`: your Stripe secret key, or a restricted key with read access to products and prices.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model uses them.

Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in Choreo Agent Builder or WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from the `product_pricing_assistant` directory.
3. Ask for a plan and a quote:

   ```bash
   curl -X POST http://localhost:9090/product-pricing-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"pricing-1","message":"We need cloud meeting recording for 25 users. Which is the lowest-tier suitable plan, and what is the total monthly price?"}'
   ```

   The catalog identifies Business as the lowest-tier plan with cloud meeting recording. With a Business price of `12.00` per user per month, 25 users cost `300.00` per month. The response includes the supporting catalog line and the calculation.

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

Answers the customer by delegating to the two specialists and combining their results. It never invents product facts or prices.

- **Query:** a feature question, optionally with a number of users to price, for example `We need cloud meeting recording for 25 users. Which plan, and what does it cost?`.
- **Response:** a `string` with the recommended plan, the supporting catalog line, and the quote with its calculation when a price was requested.
- **Tools:** `askProductSpecialist` and `askPricingSpecialist`, which pass a query to `productSpecialistAgent` and `pricingSpecialistAgent`.
- **Model:** the default WSO2 model provider.

### `productSpecialistAgent`

Recommends the lowest-tier plan that supports a feature and quotes the catalog line that supports it. The product catalog is part of its instructions. It has no tools.

### `pricingSpecialistAgent`

Calculates a monthly quote for a plan and a number of users from live Stripe prices. It finds the Stripe product whose name matches the plan exactly, reads its active recurring price, and shows the calculation.

- **Tools:** `searchProducts` and `listPrices`.

## How it works

All the code is in the `product_pricing_assistant` package:

- `agents.bal` defines the three agents and their four tools.
- `config.bal` declares the `stripeSecretKey` configurable.
- `connections.bal` creates the Stripe client, `stripeClient`, with the secret key as a bearer token.
- `main.bal` exposes `POST /product-pricing-assistant/chat` on `agentChatListener`, the shared listener on port `9090`, and runs the coordinator.
- `automation.bal`, `data_mappings.bal`, `functions.bal`, and `types.bal` are empty files that Agent Builder creates with every project.

The tools wrap Stripe actions and the specialist agents, so the models do the reasoning between them:

- `searchProducts` calls the Stripe action that searches products. The pricing specialist passes a Stripe search query such as `name:'Business'` and keeps only the product whose name matches the plan exactly, ignoring case, because a search for `Business` can also return `Business Plus`.
- `listPrices` calls the Stripe action that lists prices, for one product and active prices only. The pricing specialist picks the recurring price, divides its `unit_amount` by 100 to get the price in the currency's main unit, and multiplies it by the number of users.
- `askProductSpecialist` and `askPricingSpecialist` run the specialist agent with the coordinator's query and return its answer.

`bal build` reports no errors or warnings.

## Limitations

- The pricing specialist does the arithmetic. It shows the calculation so that you can check it, but a model can miscalculate. The division by 100 assumes a two-decimal currency.
- `listPrices` returns the first page of the product's active prices (Stripe returns 10 by default), not only recurring ones, because the form can't set the type filter. The instructions tell the pricing specialist to use the recurring price. If a product has more than 10 active prices, the recurring price can be missing from the page; if it has several active recurring prices, the model chooses one. Keep one active recurring price for each plan's product.
- The specialist tools call each specialist without a session ID, so each specialist keeps one shared conversation history for all requests and all customers. For production use, pass a session ID to each specialist.
- The product catalog is part of the product specialist's instructions. To change the plans, edit the instructions; the catalog isn't read from a file or a knowledge base.

The models choose tool arguments and interpret the catalog; a quote is not an offer. Validate plans and prices with your billing system before you show them to customers.
