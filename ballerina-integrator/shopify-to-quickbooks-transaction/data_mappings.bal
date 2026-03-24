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
// Pure arithmetic — handles month and year rollover without depending on time module.
function addDaysToDate(string dateStr, int days) returns string {
    string[] parts = re `-`.split(dateStr);

    // Expect at least "YYYY-MM-DD". If not, return the original string.
    if parts.length() < 3 {
        return dateStr;
    }

    int|error parsedY = int:fromString(parts[0]);
    int|error parsedM = int:fromString(parts[1]);
    string dayPart = parts[2].length() >= 2 ? parts[2].substring(0, 2) : parts[2];
    int|error parsedD = int:fromString(dayPart);

    // Fail fast on any parse error instead of using a hard-coded default date.
    if !(parsedY is int && parsedM is int && parsedD is int) {
        return dateStr;
    }

    int yr = <int>parsedY;
    int mo = <int>parsedM;
    int dy = <int>parsedD;

    // Validate month range before indexing daysInMonth[mo - 1].
    if mo < 1 || mo > 12 {
        return dateStr;
    }

    int[] daysInMonth = [31, isLeapYear(yr) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Validate day range for the given month.
    if dy < 1 || dy > daysInMonth[mo - 1] {
        return dateStr;
    }
    int totalDay = dy + days;

    while totalDay > daysInMonth[mo - 1] {
        totalDay -= daysInMonth[mo - 1];
        mo += 1;
        if mo > 12 {
            mo = 1;
            yr += 1;
            daysInMonth[1] = isLeapYear(yr) ? 29 : 28;
        }
    }

    return string `${yr}-${mo < 10 ? "0" : ""}${mo}-${totalDay < 10 ? "0" : ""}${totalDay}`;
}

function isLeapYear(int year) returns boolean {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}