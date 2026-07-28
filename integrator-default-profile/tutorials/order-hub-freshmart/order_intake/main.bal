import ballerina/ftp;

listener ftp:Listener ftpListener = new (protocol = ftp:FTP, host = ftpHost, auth = {credentials: {username: ftpUsername, password: ftpPassword}}, port = ftpPort);

@ftp:ServiceConfig {
    path: "/greenfield",
    fileNamePattern: "GF_.*\\.csv",
    fileAgeFilter: {minAge: 30.0},
    fileDependencyConditions: [
        {targetPattern: "GF_(.*)\\.csv", requiredFiles: ["GF_$1.ok"]}
    ]
}
service on ftpListener {
    @ftp:FunctionConfig {
        afterProcess: {
            moveTo: string `/processed`
        },
        afterError: {
            moveTo: string `/errors`
        }
    }
    remote function onFileCsv(GreenfieldRow[] greenfieldRows, ftp:FileInfo fileInfo) returns error? {
        do {
            Order orderResult = transformGreenFieldOrders(greenfieldRows);
            int[] primaryKeys = check dbClient->/orders.post([
                {
                    orderId: orderResult.orderId,
                    supplierCode: orderResult.supplierCode,
                    orderDate: {
                        year: check int:fromString(orderResult.orderDate.substring(0, 4)),
                        month: check int:fromString(orderResult.orderDate.substring(5, 7)),
                        day: check int:fromString(orderResult.orderDate.substring(8, 10))
                    },
                    orderTotal: orderResult.orderTotal,
                    currency: orderResult.currency
                }
            ]);
            foreach OrderLine orderLine in orderResult.lines {
                int[] orderlineKeys = check dbClient->/orderlines.post([
                    {
                        sku: orderLine.sku,
                        description: orderLine.description,
                        quantity: orderLine.quantity,
                        unitPrice: orderLine.unitPrice,
                        lineTotal: orderLine.lineTotal,
                        orderId: primaryKeys[0]
                    }
                ]);
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

@ftp:ServiceConfig {
    path: "/harbor",
    fileNamePattern: "HS_.*\\.xml",
    fileAgeFilter: {minAge: 30.0},
    fileDependencyConditions: [
        {targetPattern: "HS_(.*)\\.xml", requiredFiles: ["HS_$1.ok"]}
    ]
}
service on ftpListener {
    @ftp:FunctionConfig {
        afterProcess: {
            moveTo: string `/processed`
        },
        afterError: {
            moveTo: string `/errors`
        }
    }
    remote function onFileXml(HarborOrder harborOrder, ftp:FileInfo fileInfo) returns error? {
        do {
            Order orderResult = transformHarborOrders(harborOrder);
            int[] primaryKeys = check dbClient->/orders.post([
                {
                    orderId: orderResult.orderId,
                    supplierCode: orderResult.supplierCode,
                    orderDate: {
                        day: check int:fromString(orderResult.orderDate.substring(0, 2)),
                        month: check int:fromString(orderResult.orderDate.substring(3, 5)),
                        year: check int:fromString(orderResult.orderDate.substring(6, 10))
                    },
                    orderTotal: orderResult.orderTotal,
                    currency: orderResult.currency
                }
            ]);
            foreach OrderLine orderLine in orderResult.lines {
                int[] orderLineKeys = check dbClient->/orderlines.post([
                    {
                        sku: orderLine.sku,
                        description: orderLine.description,
                        quantity: orderLine.quantity,
                        unitPrice: orderLine.unitPrice,
                        lineTotal: orderLine.lineTotal,
                        orderId: primaryKeys[0]
                    }
                ]);
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
