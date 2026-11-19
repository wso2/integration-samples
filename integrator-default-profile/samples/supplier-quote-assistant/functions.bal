import ballerina/ai;
import ballerina/time;
import ballerinax/googleapis.sheets;

# Calculates the total cost of a quotation (unit price * quantity + shipping charge).
#
# + quotation - the quotation to calculate the total for
# + return - the computed total cost, or an error if the quantity or charges are invalid
@ai:AgentTool
isolated function calculateQuotationTotal(Quotation quotation) returns QuotationTotal|error {
    if quotation.quantity <= 0 {
        return error("Quantity must be positive");
    }
    if quotation.unitPrice < 0.0d || quotation.shippingCharge < 0.0d {
        return error("Unit price and shipping charge must not be negative");
    }
    decimal totalCost = quotation.unitPrice * <decimal>quotation.quantity + quotation.shippingCharge;
    QuotationTotal total = {
        supplierName: quotation.supplierName,
        totalCost: totalCost
    };
    return total;
}

# Checks whether a quotation's total cost is within the given budget.
#
# + supplierName - the name or label of the supplier
# + totalCost - the total cost of the quotation
# + budget - the budget to check against
# + return - the budget check result, or an error if the total or budget is negative
@ai:AgentTool
isolated function checkBudget(string supplierName, decimal totalCost, decimal budget) returns BudgetCheckResult|error {
    if totalCost < 0.0d || budget < 0.0d {
        return error("Total cost and budget must not be negative");
    }
    BudgetCheckResult result = {
        supplierName: supplierName,
        withinBudget: totalCost <= budget,
        totalCost: totalCost,
        budget: budget
    };
    return result;
}

# Checks whether a quoted delivery date is on or before a deadline date.
# Both dates must be in ISO `YYYY-MM-DD` format.
#
# + supplierName - the name or label of the supplier
# + deliveryDate - the quoted delivery date, in `YYYY-MM-DD` format
# + deadline - the required deadline date, in `YYYY-MM-DD` format
# + return - the deadline check result, or an error if either date is not valid ISO `YYYY-MM-DD`
@ai:AgentTool
isolated function checkDeadline(string supplierName, string deliveryDate, string deadline) returns DeadlineCheckResult|error {
    time:Utc deliveryUtc = check time:utcFromString(deliveryDate + "T00:00:00.00Z");
    time:Utc deadlineUtc = check time:utcFromString(deadline + "T00:00:00.00Z");
    DeadlineCheckResult result = {
        supplierName: supplierName,
        meetsDeadline: deliveryUtc <= deadlineUtc,
        deliveryDate: deliveryDate,
        deadline: deadline
    };
    return result;
}

# Looks up the approved budget for a requester or department from the budget tracking Google
# Sheet, instead of trusting a budget figure typed into chat.
#
# + requesterOrDepartment - the requester name or department to look up the approved budget for
# + return - the approved budget found for that requester or department, or an error if no
# matching row was found
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.sheets_3.0.0.png"}
isolated function lookupApprovedBudget(string requesterOrDepartment) returns ApprovedBudget|error {
    sheets:Range range = check budgetSheetsClient->getRange(budgetSpreadsheetId, budgetSheetName, "A1:B1000",
            "UNFORMATTED_VALUE");
    (int|string|decimal)[][] rows = range.values;
    foreach (int|string|decimal)[] row in rows {
        if row.length() < 2 {
            continue;
        }
        (int|string|decimal) nameCell = row[0];
        if nameCell is string && nameCell.toLowerAscii() == requesterOrDepartment.toLowerAscii() {
            (int|string|decimal) budgetCell = row[1];
            decimal approvedBudget;
            if budgetCell is decimal {
                approvedBudget = budgetCell;
            } else if budgetCell is int {
                approvedBudget = <decimal>budgetCell;
            } else {
                approvedBudget = check decimal:fromString(budgetCell);
            }
            ApprovedBudget result = {
                requesterOrDepartment: requesterOrDepartment,
                approvedBudget: approvedBudget
            };
            return result;
        }
    }
    return error("No approved budget found for " + requesterOrDepartment);
}
