import ballerina/log;
import ballerina/time;
import ballerinax/googleapis.sheets;
import ballerinax/trigger.shopify;

isolated string[] initializedSheets = [];

# Extracts line item details and creates a row for each line item
# + rowValues - The base row values from the order event
# + lineItems - The list of line items from the order event
# + return - A list of rows with line item details included
isolated function expandLineItems((int|string|decimal)[] rowValues, shopify:LineItem[] lineItems) returns (int|string|decimal)[][] {
    (int|string|decimal)[][] allRows = [];
    foreach var item in lineItems {
        (int|string|decimal)[] lineItemValues = rowValues.clone();
        lineItemValues.push(item?.title ?: "");
        lineItemValues.push(item?.sku ?: "");
        lineItemValues.push(item?.variant_title ?: "");
        lineItemValues.push(item?.quantity ?: 0);
        lineItemValues.push(item?.price ?: "0.00");
        lineItemValues.push(item?.product_id.toString());
        lineItemValues.push(item?.variant_id.toString());
        allRows.push(lineItemValues);
    }
    return allRows;
}

# Apply filters to determine if order should be processed
# + event - The order event
# + return - True if order should be filtered out (skipped), false if it should be processed
isolated function applyFilters(shopify:OrderEvent event) returns boolean {
    string orderNumber = event?.order_number.toString();

    if allowedCountryCodes.length() > 0 {
        string countryCode = event?.shipping_address?.country_code ?: "";
        if countryCode != "" && allowedCountryCodes.indexOf(countryCode) is () {
            log:printWarn(string `Filter failed for order ${orderNumber}: Country code '${countryCode}' not in allowed list`);
            return true;
        }
    }

    if allowedCurrencies.length() > 0 {
        string currency = event?.currency ?: "";
        if currency != "" && allowedCurrencies.indexOf(currency) is () {
            log:printWarn(string `Filter failed for order ${orderNumber}: Currency '${currency}' not in allowed list`);
            return true;
        }
    }

    if allowedSources.length() > 0 {
        string sourceName = event?.source_name ?: "";
        if sourceName != "" && allowedSources.indexOf(sourceName) is () {
            log:printWarn(string `Filter failed for order ${orderNumber}: Source '${sourceName}' not in allowed list`);
            return true;
        }
    }

    if allowedPaymentStatuses.length() > 0 {
        string financialStatus = event?.financial_status ?: "";
        if financialStatus != "" && allowedPaymentStatuses.indexOf(financialStatus) is () {
            log:printWarn(string `Filter failed for order ${orderNumber}: Financial status '${financialStatus}' not in allowed list`);
            return true;
        }
    }

    if allowedFulfillmentStatuses.length() > 0 {
        string fulfillmentStatus = event?.fulfillment_status ?: "";
        if fulfillmentStatus != "" && allowedFulfillmentStatuses.indexOf(fulfillmentStatus) is () {
            log:printWarn(string `Filter failed for order ${orderNumber}: Fulfillment status '${fulfillmentStatus}' not in allowed list`);
            return true;
        }
    }

    string orderTags = event?.tags ?: "";
    string:RegExp commaPattern = re `,`;
    
    string[] tempTagList = orderTags == "" ? [] : from string tag in commaPattern.split(orderTags) select tag.trim();    
    final string[] & readonly orderTagList = tempTagList.cloneReadOnly();
    
    if requiredTags.length() > 0 {
        if orderTagList.length() == 0 {
            log:printWarn(string `Filter failed for order ${orderNumber}: No tags found, but required tags are configured`);
            return true;
        }
        
        if !requiredTags.some(isolated function(string tag) returns boolean => orderTagList.indexOf(tag) is int) {
            log:printWarn(string `Filter failed for order ${orderNumber}: Order tags '${orderTags}' do not contain any required tags`);
            return true;
        }
    }

    if excludedTags.length() > 0 && orderTagList.length() > 0 {
        foreach string excludedTag in excludedTags {
            if orderTagList.indexOf(excludedTag) !is () {
                log:printWarn(string `Filter failed for order ${orderNumber}: Order contains excluded tag '${excludedTag}'`);
                return true;
            }
        }
    }

    return false;
}

isolated function resolveSheetName(shopify:OrderEvent event) returns string|error {
    if !groupByMonth {
        check ensureSheetExists(sheetName);
        return sheetName;
    }
    string? createdAt = event?.created_at;
    if createdAt is () {
        log:printError(string `Order ${event?.order_number.toString()} missing created_at, skipping`);
        return error("Order missing created_at date");
    }
    time:Civil civil = check time:civilFromString(createdAt);
    string month = civil.month < 10 ? string `0${civil.month}` : civil.month.toString();
    string name = string `${civil.year}-${month}`;
    check ensureSheetExists(name);
    return name;
}

isolated function ensureSheetExists(string sheetName) returns error? {
    sheets:Sheet|error sheet = sheetsClient->getSheetByName(googleSheetsConfig.spreadsheetId, sheetName);
    
    if sheet is error {
        if (!sheet.message().equalsIgnoreCaseAscii("Sheet not found")) {
            log:printError(string `Error checking for sheet '${sheetName}': ${sheet.message()}`);
            return sheet;
        }
        sheets:Sheet|error result = sheetsClient->addSheet(googleSheetsConfig.spreadsheetId, sheetName);
        if result is error {
            log:printError(string `Failed to create sheet '${sheetName}': ${result.message()}`);
            return result;
        }
        log:printInfo(string `Successfully created new sheet: ${sheetName}`);
    }
}

# create row from order event
# + event - The order event
# + return - Error if operation fails
isolated function createRowFromEvent(shopify:OrderEvent event) returns error? {
    log:printDebug(string `Received order event: ${event?.order_number.toString()}`);
    boolean shouldFilter = applyFilters(event);
    if shouldFilter {
        return;
    }

    string sheetName = check resolveSheetName(event);
    check addHeader(sheetName);

    (int|string|decimal)[] rowValues = eventToRowData(event);
    sheets:A1Range a1Range = {
        sheetName: sheetName,
        startIndex: "A",
        endIndex: "AAA"
    };

    if insertMode == APPEND {
        if includeLineItems {
            var lineItems = event?.line_items;

            if !(lineItems is ()) && lineItems.length() > 0 {
                (int|string|decimal)[][] allRows = expandLineItems(rowValues, lineItems);
                _ = check sheetsClient->appendValues(googleSheetsConfig.spreadsheetId, allRows, a1Range);
                return;
            } 
        }
        _ = check sheetsClient->appendValue(googleSheetsConfig.spreadsheetId, rowValues, a1Range);
    } else {
        if includeLineItems {
            check upsertOrderWithLineItems(event, rowValues, a1Range, sheetName);
        } else {
            check upsertOrderWithoutLineItems(event, rowValues, a1Range, sheetName);
        }
    }
}

# Adds the header row for an empty sheet
# + sheetName - Target sheet name
# + return - Error if operation fails
isolated function addHeader(string sheetName) returns error? {
    lock {
        if (initializedSheets.indexOf(sheetName) is int) {
            return;
        }
    }
    
    sheets:Row firstRow = check sheetsClient->getRow(googleSheetsConfig.spreadsheetId, sheetName, 1);
    (int|string|decimal)[] firstRowValues = firstRow.values;

    if firstRowValues.length() == 0 {
        (int|string|decimal)[] headerRow = [
            // Order Identifiers
            "ID",
            "Order Number",
            "Created At",
            "Updated At",
            
            // Financial Summary
            "Total Price",
            "Subtotal Price",
            "Total Tax",
            "Total Discounts",
            "Shipping Price",
            "Line Items Total",
            "Currency",
            
            // Payment Details
            "Financial Status",
            "Payment Gateway",
            "Discount Codes",
            
            // Order Status
            "Fulfillment Status",
            "Processed At",
            "Cancelled At",
            
            // Customer Information
            "Customer ID",
            "Email",
            "Customer First Name",
            "Customer Last Name",
            "Customer Phone",
            "Order Phone",
            
            // Shipping Address
            "Ship First Name",
            "Ship Last Name",
            "Ship Address 1",
            "Ship Address 2",
            "Ship City",
            "Ship Province",
            "Ship Zip",
            "Ship Country",
            "Ship Country Code",
            "Ship Phone",
            "Shipping Method",
            
            // Billing Address
            "Bill First Name",
            "Bill Last Name",
            "Bill Address 1",
            "Bill City",
            "Bill Province",
            "Bill Zip",
            "Bill Country",
            
            // Order Metadata
            "Source Name",
            "Referring Site",
            "Tags",
            "Note",
            "Total Weight"
        ];
        if includeLineItems {
            headerRow.push("Line Item Title");
            headerRow.push("Line Item SKU");
            headerRow.push("Line Item Variant Title");
            headerRow.push("Line Item Quantity");
            headerRow.push("Line Item Price");
            headerRow.push("Line Item Product ID");
            headerRow.push("Line Item Variant ID");
        }
        check sheetsClient->createOrUpdateRow(googleSheetsConfig.spreadsheetId, sheetName, 1, headerRow);
    }
    lock {
        initializedSheets.push(sheetName);
    }
}

# Upsert order without line items (single row per order)
# + event - The order event
# + rowValues - The row values to upsert
# + a1Range - The A1 range for appending
# + sheetName - Target sheet name
# + return - Error if operation fails
isolated function upsertOrderWithoutLineItems(shopify:OrderEvent event, (int|string|decimal)[] rowValues, sheets:A1Range a1Range, string sheetName) returns error? {
    sheets:Column orderNumberRowData = check sheetsClient->getColumn(googleSheetsConfig.spreadsheetId, sheetName, "B");
    (int|string|decimal)[] orderNums = orderNumberRowData.values;

    foreach int|string|decimal num in orderNums {
        if (num.toString() == event?.order_number.toString()) {
            int|() index = orderNums.indexOf(num);
            if (index is ()) {
                continue;
            }
            check sheetsClient->createOrUpdateRow(googleSheetsConfig.spreadsheetId, sheetName, index + 1, rowValues);
            return;
        }
    }
    
    _ = check sheetsClient->appendValue(googleSheetsConfig.spreadsheetId, rowValues, a1Range);
}

# Upsert order with line items (multiple rows per order)
# + event - The order event
# + rowValues - The base row values
# + a1Range - The A1 range for appending
# + sheetName - Target sheet name
# + return - Error if operation fails
isolated function upsertOrderWithLineItems(shopify:OrderEvent event, (int|string|decimal)[] rowValues, sheets:A1Range a1Range, string sheetName) returns error? {
    sheets:Column orderNumberRowData = check sheetsClient->getColumn(googleSheetsConfig.spreadsheetId, sheetName, "B");
    (int|string|decimal)[] orderNums = orderNumberRowData.values;

    int[] matchingRowIndices = [];
    foreach int i in 0 ..< orderNums.length() {
        int|string|decimal num = orderNums[i];
        if (num.toString() == event?.order_number.toString()) {
            matchingRowIndices.push(i + 1);
        }
    }

    // Build all rows with line items
    var lineItems = event?.line_items;
    (int|string|decimal)[][] allRows = [];
    if !(lineItems is ()) && lineItems.length() > 0 {
        allRows = expandLineItems(rowValues, lineItems);
    } else {
        // No line items, just use base row
        allRows.push(rowValues);
    }

    // If matching rows found, replace them at the same position
    if matchingRowIndices.length() > 0 {
        int firstRowPosition = matchingRowIndices[0];        
        int[] sortedIndices = matchingRowIndices.sort("descending");
        int i = 0;
        while i < sortedIndices.length() {
            int startRow = sortedIndices[i];
            int count = 1;
            while i + count < sortedIndices.length() && sortedIndices[i + count] == startRow - count {
                count += 1;
            }
            check sheetsClient->deleteRowsBySheetName(googleSheetsConfig.spreadsheetId, sheetName, startRow - count + 1, count);
            i += count;
        }
        
        int numberOfNewRows = allRows.length();
        check sheetsClient->addRowsBeforeBySheetName(googleSheetsConfig.spreadsheetId, sheetName, firstRowPosition, numberOfNewRows);
        
        int lastRowPosition = firstRowPosition + numberOfNewRows - 1;
        string rangeNotation = string `A${firstRowPosition}:AAA${lastRowPosition}`;
        sheets:Range rangeToSet = {
            a1Notation: rangeNotation,
            values: allRows
        };
        check sheetsClient->setRange(googleSheetsConfig.spreadsheetId, sheetName, rangeToSet);
    } else {
        _ = check sheetsClient->appendValues(googleSheetsConfig.spreadsheetId, allRows, a1Range);
    }
}
