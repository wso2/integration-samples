
function transformGreenFieldOrders(GreenfieldRow[] greenFieldRows) returns Order => let decimal[] lineTotals = from var greenFieldRowsItem in greenFieldRows
        select <decimal>greenFieldRowsItem.qty * greenFieldRowsItem.unit_price
    in {
        orderId: greenFieldRows[0].order_id,
        orderDate: greenFieldRows[0].order_date,
        lines: from var greenFieldRowsItem in greenFieldRows
            select {sku: greenFieldRowsItem.sku, description: greenFieldRowsItem.description, quantity: greenFieldRowsItem.qty, unitPrice: greenFieldRowsItem.unit_price, lineTotal: <decimal>greenFieldRowsItem.qty * greenFieldRowsItem.unit_price},
        currency: "USD",
        orderTotal: from var lineTotalsItem in lineTotals
            collect sum(lineTotalsItem),
        supplierCode: "GREENFIELD"
    };

function transformHarborOrders(HarborOrder harborOrder) returns Order => let decimal[] lineTotals = from var itemItem in harborOrder.items.item
        select (let decimal|error tmp = decimal:fromString(itemItem.price) in (tmp is error ? 0.0d : tmp)) * let decimal|error tmp = decimal:fromString(itemItem.units) in (tmp is error ? 0.0d : tmp)
    in {
        orderId: harborOrder.id,
        currency: harborOrder.currency,
        supplierCode: "HARBOR",
        lines: from var itemItem in harborOrder.items.item
            select {sku: itemItem.code, description: itemItem.name, unitPrice: (let decimal|error tmp = decimal:fromString(itemItem.price) in (tmp is error ? 0.0d : tmp)), quantity: (let int|error tmp = int:fromString(itemItem.units) in (tmp is error ? 0 : tmp)), lineTotal: (let decimal|error tmp = decimal:fromString(itemItem.price) in (tmp is error ? 0.0d : tmp)) * (let decimal|error tmp = decimal:fromString(itemItem.units) in (tmp is error ? 0.0d : tmp))},
        orderTotal: from var lineTotalsItem in lineTotals
            collect sum(lineTotalsItem),
        orderDate: harborOrder.date
    };
