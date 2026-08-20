import ballerina/lang.array;
import ballerina/log;
import ballerina/time;

public function main() returns error? {
    do {
        time:Utc timeUtc = time:utcNow();
        time:Civil timeCivil = time:utcToCivil(timeUtc);
        time:Date date = {year: timeCivil.year, month: timeCivil.month, day: timeCivil.day};
        OrderSummaryType[] orderSummary = check dbClient->/orders.get(whereClause = `order_date = ${date}`);
        string[] orderRows = [];
        int orderCount = 0;
        foreach OrderSummaryType orderItem in orderSummary {
            array:push(orderRows, string `<tr>
                <td>${orderItem.orderId}</td>
                <td>${orderItem.supplierCode}</td>
                <td>${orderItem.currency} ${orderItem.orderTotal}</td>
            </tr>`);
            orderCount = orderCount + 1;
        }
        string htmlBody = string `<html>
            <body>
                <h2>Daily summary : ${date.day}/${date.month}/${date.year}</h2>
                <h2>Total orders today : ${orderCount}</h2>
                <table border="1" cellpadding="8" cellspacing="0">
                    <tr>
                        <th>Order ID</th>
                        <th>Supplier</th>
                        <th>Order Total</th>
                    </tr>
                    ${string:'join("", ...orderRows)}
                </table>
            </body>
        </html>`;
        check emailSmtpclient->sendMessage({
            to: "procurement@freshmart.com",
            subject: string `Daily summary : ${date.day}/${date.month}/${date.year}`,
            'from: "procurementbot@example",
            htmlBody: htmlBody
        });

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
