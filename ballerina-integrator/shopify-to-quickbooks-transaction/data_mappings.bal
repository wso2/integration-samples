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

            QBSalesLine line = {
                DetailType: "SalesItemLineDetail",
                Amount: qty * price,
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

    // 3. Discount line (optional — negative amount)
    string? totalDiscountsStr = event?.total_discounts;
    if quickbooksConfig.includeDiscountLineItems {
        if totalDiscountsStr is string {
            decimal totalDiscounts = check decimal:fromString(totalDiscountsStr);
            if totalDiscounts > 0.0d {
                string discountDesc = buildDiscountDescription(event);
                string discountItemId = check lookupQBItemId(quickbooksConfig.discountItemName);
                QBSalesLine discountLine = {
                    DetailType: "SalesItemLineDetail",
                    Amount: -totalDiscounts,
                    Description: discountDesc,
                    SalesItemLineDetail: {
                        ItemRef: {value: discountItemId}
                    }
                };
                lines.push(discountLine);
            }
        }
    }

    return lines;
}

// Build discount description from discount_codes and discount_applications
function buildDiscountDescription(shopify:OrderEvent event) returns string {
    string[] names = [];

    // Collect codes from discount_codes[]
    shopify:DiscountCode[]? discountCodes = event?.discount_codes;
    if discountCodes is shopify:DiscountCode[] {
        foreach shopify:DiscountCode dc in discountCodes {
            string code = dc?.code ?: "";
            if code != "" {
                names.push(code);
            }
        }
    }

    // If no codes, try titles from discount_applications[]
    if names.length() == 0 {
        shopify:DiscountApplication[]? discountApps = event?.discount_applications;
        if discountApps is shopify:DiscountApplication[] {
            foreach shopify:DiscountApplication da in discountApps {
                string title = da?.title ?: da?.description ?: "";
                if title != "" {
                    names.push(title);
                }
            }
        }
    }

    if names.length() == 0 {
        return "Discount";
    }
    return "Discount: " + string:'join(", ", ...names);
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
// Uses time:civilAddDuration to handle month/year rollover and leap years correctly.
// Falls back to returning the original string if the input cannot be parsed.
function addDaysToDate(string dateStr, int days) returns string {
    string[] parts = re `-`.split(dateStr);
    if parts.length() < 3 {
        return dateStr;
    }

    int|error parsedY = int:fromString(parts[0]);
    int|error parsedM = int:fromString(parts[1]);
    string dayPart = parts[2].length() >= 2 ? parts[2].substring(0, 2) : parts[2];
    int|error parsedD = int:fromString(dayPart);

    if !(parsedY is int && parsedM is int && parsedD is int) {
        return dateStr;
    }

    time:Civil civil = {
        year: parsedY,
        month: parsedM,
        day: parsedD,
        hour: 0,
        minute: 0,
        second: 0
    };

    time:Civil|time:Error result = time:civilAddDuration(civil, {days: days});
    if result is time:Error {
        return dateStr;
    }

    int yr = result.year;
    int mo = result.month;
    int dy = result.day;
    return string `${yr}-${mo < 10 ? "0" : ""}${mo}-${dy < 10 ? "0" : ""}${dy}`;
}
