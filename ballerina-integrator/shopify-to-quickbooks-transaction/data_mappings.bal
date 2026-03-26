import ballerina/time;
import ballerinax/quickbooks.online as quickbooks;
import ballerinax/trigger.shopify;

// --- Build QuickBooks line items from a Shopify order ---
function buildLineItems(shopify:OrderEvent event) returns anydata[]|error {
    anydata[] lines = [];

    // 1. Product line items
    shopify:OrderLineItem[]? lineItems = event?.line_items;
    if lineItems is shopify:OrderLineItem[] {
        foreach shopify:OrderLineItem item in lineItems {
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
    }

    // 2. Shipping line (optional)
    shopify:ShippingLine[]? shippingLines = event?.shipping_lines;
    if quickbooksConfig.mapShippingAsSeparateLine && shippingLines is shopify:ShippingLine[] && shippingLines.length() > 0 {
        decimal totalShipping = 0.0d;
        string[] shippingDescs = [];
        foreach shopify:ShippingLine sl in shippingLines {
            totalShipping += check decimal:fromString(sl?.price ?: "0");
            shippingDescs.push(sl?.title ?: "Shipping");
        }
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

    return lines;
}

// --- Map Shopify order to QuickBooks InvoiceCreateObject ---
// Note: The ballerinax/quickbooks.online v1.5.1 connector supports Invoice (not SalesReceipt).
// Both SALES_RECEIPT and INVOICE transaction types are sent as QB Invoices.
// For INVOICE mode, a DueDate (+30 days) is added; for SALES_RECEIPT mode, no DueDate is set.
function mapToQBTransaction(shopify:OrderEvent event, string customerId) returns quickbooks:InvoiceCreateObject|error {
    anydata[] lines = check buildLineItems(event);
    string txnDate = formatTxnDate(event?.created_at);

    quickbooks:InvoiceCreateObject invoice = {
        CustomerRef: {value: customerId},
        TxnDate: txnDate,
        CurrencyRef: {value: event?.currency ?: "USD"},
        PrivateNote: buildMemo(event),
        Line: lines
    };

    // Only add DueDate for INVOICE mode (for SALES_RECEIPT mode, QB Invoice without DueDate acts like a receipt)
    if quickbooksConfig.transactionType == "INVOICE" {
        invoice.DueDate = addDaysToDate(txnDate, 30);
    }

    return invoice;
}

// --- Add N calendar days to a YYYY-MM-DD string ---
// Uses time:civilFromString to safely parse the input, and time:civilAddDuration
// to handle month/year rollover and leap years correctly.
// Falls back to returning the original string if the input cannot be parsed.
function addDaysToDate(string dateStr, int days) returns string {
    // time:civilFromString expects RFC 3339 format (e.g., "YYYY-MM-DDThh:mm:ss.sZ")
    string isoStr = dateStr + "T00:00:00.00Z";
    
    time:Civil|time:Error civil = time:civilFromString(isoStr);
    if civil is time:Error {
        return dateStr;
    }

    time:Civil|time:Error result = time:civilAddDuration(civil, {days: days});
    if result is time:Error {
        return dateStr;
    }

    int yr = result.year;
    int mo = result.month;
    int dy = result.day;
    return string `${yr}-${mo < 10 ? "0" : ""}${mo}-${dy < 10 ? "0" : ""}${dy}`;
}
