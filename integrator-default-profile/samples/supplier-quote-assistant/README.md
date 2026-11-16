# Supplier quote comparison assistant

This sample compares supplier quotations pasted into chat. It uses tools to calculate each total, check the budget, and check the delivery deadline, then recommends the lowest-cost eligible offer.

The agent does not contact suppliers, approve purchases, or place orders.

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

Use the service URL and access token supplied by the provider command, not the placeholders. This sample does not need an embedding provider. Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Compare three quotations:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-1","message":"Compare quotes for 100 units, with a budget of 1200 and a delivery deadline of 2027-06-20. All amounts are USD. Supplier A: 10 per unit, 50 shipping, delivery 2027-06-19. Supplier B: 9 per unit, 20 shipping, delivery 2027-06-22. Supplier C: 11 per unit, free shipping, delivery 2027-06-20."}'
   ```

   Supplier A totals `1050` and meets both constraints. Supplier B costs less at `920`, but misses the deadline. Supplier C meets both constraints at `1100`. The sample rules select Supplier A.

4. Try a quotation with missing information:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-2","message":"I need 50 units by 2027-06-20 with a budget of 600 USD. Supplier D quotes 10 USD per unit and delivery on 2027-06-19, but has not specified shipping."}'
   ```

   The instructions require the agent to ask for the shipping charge before calculating that supplier's total. Reply with the missing value using the same `sessionId`.

A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Test the tools

Run `bal test --offline` from this directory. The tests cover decimal totals, budget and deadline boundaries, invalid dates, and invalid quantities or monetary values.

`tests/Config.toml` contains a loopback URL and an unused placeholder token. The tests initialize providers but do not call model services. They do not test quotation extraction or chat recommendations.

## How it works

- `agents.bal` defines the comparison instructions and three tools.
- `calculateQuotationTotal` calculates `unitPrice * quantity + shippingCharge` with decimal arithmetic. It requires a positive quantity and nonnegative charges.
- `checkBudget` accepts totals less than or equal to the budget. It rejects negative totals or budgets.
- `checkDeadline` compares delivery and deadline dates in `YYYY-MM-DD` format. Invalid dates return an error.
- `automation.bal` exposes `POST /supplier-quote-assistant/chat` through the AI listener.

Use explicit dates for repeatable comparisons. The model extracts the quotation values and passes them to tools. Taxes and currency conversion are outside this sample. Validate quantities, amounts, dates, and supplier data independently before using a recommendation in a purchasing system.
