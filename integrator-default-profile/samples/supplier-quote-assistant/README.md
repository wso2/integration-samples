# Supplier quote comparison assistant

This sample compares supplier quotations pasted into chat and recommends the lowest-cost offer that covers the full quantity, stays within the requester's approved budget, and meets the delivery deadline. It reads the approved budget from a Google Sheet.

Every file in this sample comes from Choreo Agent Builder's forms: the agent, the Google Sheets connection and its configurables, three tools made from a Google Sheets action and standard library functions, and the Agent Chat entry point. You can build the same project in Agent Builder without writing code.

The agent compares and recommends only. It does not contact suppliers, approve purchases, or place orders, and it reads the budget sheet without writing to it.

## Prerequisites

- Ballerina `2201.14.2` and Choreo Agent Builder, or WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Google Sheet that lists approved budgets. Name the tab `Budgets`, put each requester or department name in column A, and put the approved budget in column B:

  | A | B |
  |---|---|
  | Requester or department | Approved budget |
  | Facilities | 1200 |
  | IT Operations | 950 |

- A Google Cloud OAuth 2.0 client ID and secret, and a refresh token that grants the `https://www.googleapis.com/auth/spreadsheets.readonly` scope. You can get the refresh token from the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) by using your own client credentials.

## Configuration

The sample is a workspace with one package, `supplier_quote_assistant`. Create `Config.toml` in the `supplier_quote_assistant` directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Google Sheets values yourself, above that table:

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
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model uses them.

If your budget tab has a different name, add `budgetSheetName = "TAB_NAME"` next to `budgetSpreadsheetId`. A setting placed below the `[ballerina.ai.wso2ProviderConfig]` line belongs to the provider table and has no effect on the sample. Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in Choreo Agent Builder or WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from the `supplier_quote_assistant` directory.
3. Compare three quotations for the Facilities department:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-1","message":"I am from Facilities. Compare quotes for 100 units with a delivery deadline of 2027-06-20. All amounts are USD. Supplier A: 10 per unit, 50 shipping, delivery 2027-06-19. Supplier B: 9 per unit, 20 shipping, delivery 2027-06-22. Supplier C: 11 per unit, free shipping, delivery 2027-06-20."}'
   ```

   With the example sheet, the approved budget for Facilities is `1200`. Supplier A totals `1050` and meets both rules. Supplier B costs less at `920`, but misses the deadline. Supplier C meets both rules at `1100`. The agent recommends Supplier A and explains why Supplier B doesn't qualify.

4. Try a quotation with missing information:

   ```bash
   curl -X POST http://localhost:9090/supplier-quote-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"quotes-2","message":"IT Operations needs 50 units by 2027-06-20. Supplier D quotes 10 USD per unit and delivery on 2027-06-19, but has not specified shipping."}'
   ```

   The instructions require the agent to ask for the shipping charge before it calculates that supplier's total. Reply with the missing value using the same `sessionId`.

A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `supplierQuoteAgent`

Compares supplier quotations and recommends the lowest-cost supplier that covers the full quantity, stays within the approved budget, and meets the delivery deadline. It explains why each cheaper supplier doesn't qualify.

- **Query:** the requester or department, the quantity, the deadline, and one quotation per supplier (unit price, shipping charge, delivery date). Relative dates such as "Friday" work because the agent reads today's date (UTC) from a tool.
- **Response:** a `string` with each total's calculation, the recommended supplier, and the reason each other supplier was excluded. The agent asks for a missing requester, shipping charge, delivery date, or full-quantity quotation before it ranks a supplier.
- **Tools:** `readBudgetSheet`, `getCurrentTime`, `formatTime`.
- **Model:** the default WSO2 model provider.

## How it works

All the code is in the `supplier_quote_assistant` package:

- `agents.bal` defines the agent and its three tools. The instructions hold the comparison rules and the steps the agent follows, including which tool to call at each step.
- `config.bal` declares the `sheetsClientId`, `sheetsClientSecret`, `sheetsRefreshToken`, and `budgetSpreadsheetId` configurables, and `budgetSheetName` with the default value `Budgets`.
- `connections.bal` creates the Google Sheets client, `budgetSheetsClient`, with OAuth 2.0 refresh token authentication and the connector's default token endpoint.
- `main.bal` exposes `POST /supplier-quote-assistant/chat` on `agentChatListener`, the shared listener on port `9090`.
- `automation.bal`, `data_mappings.bal`, `functions.bal`, and `types.bal` are empty files that Agent Builder creates with every project.

The tools wrap a Google Sheets action and standard library functions, so the model does the reasoning between them:

- `readBudgetSheet` calls the Google Sheets action that gets a range. It reads `A1:B1000` from the configured spreadsheet and tab, and takes no input from the model, so the model can't read another spreadsheet. The agent finds the requester's row in the result, ignoring case, and uses its budget instead of a figure typed into chat.
- `getCurrentTime` and `formatTime` wrap `time:utcNow` and `time:utcToString`. The agent reads today's date from the ISO 8601 string that `formatTime` returns and uses it to resolve relative dates.

The agent calculates each total as unit price times quantity plus shipping charge and shows the calculation in its reply. It then compares each total with the budget, and each delivery date with the deadline as `YYYY-MM-DD` dates.

`bal build` reports two `undocumented return parameter` warnings, one for each time tool. Agent Builder copies the library function's parameter documentation but doesn't write a return line. The warnings don't affect the build.

## Limitations

- The model does the arithmetic. It shows each calculation so that you can check it, but a model can miscalculate, especially with many decimal places. Check the totals before you act on a recommendation.
- The model reads the sheet's rows and finds the budget itself. A name below row 1000 isn't read, and the model extracts the requester name from the message, so it can look up another department's budget if asked.
- Today's date is in UTC, so near midnight a relative date such as "tomorrow" can resolve to a different day than the requester's local date. Use explicit dates for repeatable comparisons.
- Taxes and currency conversion are outside this sample.

The model chooses tool arguments and applies the rules; its recommendation is not an approval. Authenticate requesters and validate quantities, amounts, dates, and supplier data independently before you use a recommendation in a purchasing system.
