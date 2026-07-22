import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// --- Build QuickBooks line items from a Shopify order ---
function buildLineItems(shopify:OrderEvent event) returns anydata[]|error {
    anydata[] lines = [];

    // #1: Use type narrowing with ?: [] to avoid separate null check
    foreach shopify:OrderLineItem item in (event?.line_items ?: []) {
        string itemId = check lookupQBItemId(item?.sku);
        decimal qty = <decimal>(item?.quantity ?: 0);
        decimal price = check decimal:fromString(item?.price ?: "0");
        decimal lineDiscount = check decimal:fromString(item?.total_discount ?: "0");

        // Subtract the total line discount (item-level + apportioned order-level) to get the net line amount
        decimal netAmount = (qty * price) - lineDiscount;

        QBSalesLine line = {
            DetailType: "SalesItemLineDetail",
            Amount: netAmount,
            Description: item?.title ?: "",
            SalesItemLineDetail: {
                ItemRef: {value: itemId},
                UnitPrice: price,
                Qty: qty,
                TaxCodeRef: {value: resolveTaxCode(item?.tax_lines)}
            }
        };
        lines.push(line);
    }

    // 2. Shipping line (optional)
    if quickbooksConfig.mapShippingAsSeparateLine {
        decimal totalShipping = 0.0d;
        string[] shippingDescs = [];
        foreach shopify:ShippingLine sl in (event?.shipping_lines ?: []) {
            totalShipping += check decimal:fromString(sl?.price ?: "0");
            shippingDescs.push(sl?.title ?: "Shipping");
        }
        if totalShipping > 0.0d {
            string shippingItemId = check lookupQBItemId(quickbooksConfig.shippingItemName);
            QBSalesLine shippingLine = {
                DetailType: "SalesItemLineDetail",
                Amount: totalShipping,
                Description: string:'join(", ", ...shippingDescs),
                SalesItemLineDetail: {
                    ItemRef: {value: shippingItemId}
                }
            };
            lines.push(shippingLine);
        }
    }

    return lines;
}

// --- Map Shopify order to QuickBooks InvoiceCreateObject ---
function mapToQBTransaction(shopify:OrderEvent event, string customerId) returns quickbooks:InvoiceCreateObject|error {
    anydata[] lines = check buildLineItems(event);
    string txnDate = formatTxnDate(event?.created_at);

    quickbooks:InvoiceCreateObject invoice = {
        CustomerRef: {value: customerId},
        TxnDate: txnDate,
        CurrencyRef: {value: event?.currency ?: "USD"},
        PrivateNote: buildMemo(event),
        Line: lines,
        // #3: Use inline ternary for DueDate (only for INVOICE mode)
        DueDate: quickbooksConfig.transactionType == "INVOICE" ? addDaysToDate(txnDate, quickbooksConfig.invoiceDueDays) : ()
    };

    return invoice;
}

// #6: Use .padZero(2) for zero-padding
function addDaysToDate(string dateStr, int days) returns string {
    // time:civilFromString expects RFC 3339 format
    string isoStr = dateStr + "T00:00:00.00Z";

    time:Civil|time:Error civil = time:civilFromString(isoStr);
    if civil is time:Error {
        return dateStr;
    }

    time:Civil|time:Error result = time:civilAddDuration(civil, {days: days});
    if result is time:Error {
        return dateStr;
    }

    return string `${result.year}-${result.month < 10 ? "0" : ""}${result.month}-${result.day < 10 ? "0" : ""}${result.day}`;
}
