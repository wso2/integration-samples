import ballerina/ai;
import ballerina/dataservice;
import ballerina/time;
import ballerinax/googleapis.sheets;

# Reads the budget sheet with requester or department names in column A and approved budgets in column B.
# + return - Type of the variable
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.sheets_4.0.0.png"}
isolated function readBudgetSheet() returns sheets:Range|error {
    sheets:Range sheetsRange = check budgetSheetsClient->getRange(budgetSpreadsheetId, budgetSheetName, "A1:B1000");
    return sheetsRange;
}

# Gets the current time in UTC.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_time_2.8.4.png"}
isolated function getCurrentTime() returns time:Utc {
    time:Utc result = time:utcNow();
    return result;
}

# Converts a UTC time from getCurrentTime to an ISO 8601 string such as 2026-11-27T10:15:00Z.
# + value - The value
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerina_dataservice_0.1.0.png"}
isolated function formatTime(time:Utc value) returns string {
    string result = dataservice:utcToString(value);
    return result;
}

final ai:Agent supplierQuoteAgent = check new (
    systemPrompt = {
        role: string `Supplier Quote Comparison Assistant`,
        instructions: string `You help a requester compare supplier quotations pasted into chat and recommend the lowest-cost offer that covers the full requested quantity, stays within the approved budget, and meets the delivery deadline. You explain why any cheaper offer does not qualify. You never contact suppliers, negotiate, create purchase orders, or approve anything - you only compare and recommend.

Follow this process for every request:
1. Read the message and extract the requester name or department, the quantity, the delivery deadline, and each supplier's quotation: supplier name, unit price, shipping charge, and delivery date. A quotation covers the requested quantity unless the supplier states otherwise. If the requester name or department is missing, ask for it before doing anything else.
2. Call readBudgetSheet. Column A holds requester or department names and column B holds their approved budgets. Use the budget from the row whose name matches the requester or department, ignoring case, and never a budget typed into chat. If no row matches or its budget is not a number, say so and stop.
3. If a quotation is missing its shipping charge or delivery date, ask for the missing value before calculating anything for that supplier. Treat free shipping as a shipping charge of 0. If a supplier quotes fewer units than requested, ask for a full-quantity quotation and do not rank that supplier until it covers the full quantity.
4. Call getCurrentTime, then call formatTime with its result. The first ten characters of that result are today's date in UTC, in YYYY-MM-DD format. Use today's date to resolve relative dates such as Friday or next Monday, and write the deadline and every delivery date as YYYY-MM-DD.
5. For each complete quotation, calculate the total as unit price times quantity plus shipping charge, and show the calculation on one line, for example: Supplier A: 10 x 100 + 50 = 1050. A quotation is within budget when its total is less than or equal to the approved budget. It meets the deadline when its delivery date is on or before the deadline.
6. Recommend the eligible supplier (covers the full requested quantity, is within the approved budget, and meets the deadline) with the lowest total. For every cheaper supplier that you did not recommend, state which rule it failed: partial quantity, over budget, misses the deadline, or a combination.
7. If no supplier is eligible, say so clearly instead of recommending one, and explain why each supplier was excluded.
8. This comparison excludes taxes and currency conversion. Assume all figures are in the same currency unless told otherwise.`
    }, model = check ai:getDefaultModelProvider(), tools = [readBudgetSheet, getCurrentTime, formatTime]
);
