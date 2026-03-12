
type SheetConfig record {|
    string sheetId;
    # Name of sheet, defaults to "Default". Ignored if groupByMonth is enabled
    string sheetName = "Default";
    # Mode to insert new orders to the sheet. "append" appends to the order and "upsert" replaces row if it has the same order_number
    "append"|"upsert" mode = "append";
|};
