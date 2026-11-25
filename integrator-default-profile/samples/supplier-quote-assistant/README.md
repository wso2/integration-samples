# Supplier quote comparison assistant

This sample compares supplier quotations pasted into chat. It reads the requester's approved budget from a Google Sheet, uses tools to calculate each total and check the budget and delivery deadline, then recommends the lowest-cost eligible offer.

The agent does not contact suppliers, approve purchases, or place orders. It reads the budget sheet but never writes to it.

## Prerequisites

- Ballerina `2201.14.1` and WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Google Sheet that lists approved budgets. Name the tab `Budgets`, put each requester or department name in column A, and put the approved budget in column B as a number:

  | A | B |
  |---|---|
  | Requester or department | Approved budget |
  | Facilities | 1200 |
  | IT Operations | 950 |

- A Google Cloud OAuth 2.0 client ID and secret, and a refresh token that grants the `https://www.googleapis.com/auth/spreadsheets.readonly` scope. You can get the refresh token from the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) by using your own client credentials.

## Configuration

Create `Config.toml` in the sample directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Google Sheets values yourself:

```toml
sheetsClientId = "GOOGLE_CLIENT_ID"
sheetsClientSecret = "GOOGLE_CLIENT_SECRET"
sheetsRefreshToken = "GOOGLE_REFRESH_TOKEN"
budgetSpreadsheetId = "SPREADSHEET_ID"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REFRESH_TOKEN`: your OAuth 2.0 credentials.
- `SPREADSHEET_ID`: the ID in the sheet's URL, between `/d/` and `/edit`.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. This sample does not need an embedding provider.

If your budget tab has a different name, add `budgetSheetName = "TAB_NAME"` next to `budgetSpreadsheetId`, above the `[ballerina.ai.wso2ProviderConfig]` line. A setting placed below that line belongs to the provider table and has no effect on the sample. The client requests an access token at startup, so the integration doesn't start with invalid Google credentials. Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Compare three quotations for the Facilities department:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-1","message":"I am from Facilities. Compare quotes for 100 units with a delivery deadline of 2027-06-20. All amounts are USD. Supplier A: 10 per unit, 50 shipping, delivery 2027-06-19. Supplier B: 9 per unit, 20 shipping, delivery 2027-06-22. Supplier C: 11 per unit, free shipping, delivery 2027-06-20."}'
   ```

   With the example sheet, the approved budget for Facilities is `1200`. Supplier A totals `1050` and meets both constraints. Supplier B costs less at `920`, but misses the deadline. Supplier C meets both constraints at `1100`. The sample rules select Supplier A.

4. Try a quotation with missing information:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-2","message":"IT Operations needs 50 units by 2027-06-20. Supplier D quotes 10 USD per unit and delivery on 2027-06-19, but has not specified shipping."}'
   ```

   The instructions require the agent to ask for the shipping charge before calculating that supplier's total. Reply with the missing value using the same `sessionId`.

A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `supplierQuoteAgent`

Compares supplier quotations pasted into chat and recommends the lowest-cost supplier that covers the full quantity, stays within the approved budget, and meets the delivery deadline. It explains why each cheaper supplier does not qualify.

- **Query:** the requester or department, the quantity, the deadline, and one quotation per supplier (unit price, shipping charge, delivery date). The agent reads today's date (UTC) from a tool so relative dates such as "Friday" resolve correctly.
- **Response:** a `string` with the recommended supplier and the reason each other supplier was excluded. The agent asks for a missing requester, shipping charge, delivery date, or full-quantity quotation before ranking a supplier.
- **Tools:** `getCurrentDate`, `lookupApprovedBudget`, `calculateQuotationTotal`, `checkBudget`, `checkDeadline`.
- **Initialization parameters:** `model`, the model provider the agent uses.

## How it works

- `agents.bal` defines the comparison instructions and five tools.
- `getCurrentDate` returns today's date in UTC.
- `connections.bal` creates the Google Sheets client from the OAuth 2.0 configuration.
- `lookupApprovedBudget` reads columns A and B of the budget tab and returns the budget of the first row whose name matches, ignoring case. A budget cell that isn't a number returns an error that names the cell's value. The agent uses this value instead of a budget typed into chat.
- `calculateQuotationTotal` calculates `unitPrice * quantity + shippingCharge` with decimal arithmetic. It requires a positive quantity and nonnegative charges.
- `checkBudget` accepts totals less than or equal to the budget. It rejects negative totals or budgets.
- `checkDeadline` compares delivery and deadline dates in `YYYY-MM-DD` format. Invalid dates return an error.
- `automation.bal` exposes `POST /supplier-quote-assistant/chat` through the AI listener.

Use explicit dates for repeatable comparisons. The model extracts the quotation values and the requester name and passes them to tools, so it can look up another department's budget if asked. Taxes and currency conversion are outside this sample. Authenticate requesters and validate quantities, amounts, dates, and supplier data independently before you use a recommendation in a purchasing system.
