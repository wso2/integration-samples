import ballerina/log;

// Function to generate email content for shipment
public function generateShipmentEmailBody(ShipmentMessage message) returns string {
    string productList = "";
    foreach Product product in message.products {
        productList += string `- ${product.productCode}: ${product.qty} units ${"\n\t    "}`;
    }

    return string `
            Dear ${message.customerName},

            Your shipment has been received and is being processed.

            Shipment Details:
            - Shipment ID: ${message.shipmentId}
            - Customer ID: ${message.customerId}
            - Shipment Date: ${message.shipmentDate}
            - Status: ${message.status}

            Products:
            ${productList}

            We will notify you once your shipment is ready for delivery.

            Best regards,
            Invoice Team
                `;
}

// Function to send shipment notification email
public function sendShipmentNotification(ShipmentMessage message, string? correlationId) returns error? {
    string emailBody = generateShipmentEmailBody(message);
    string subject = string `Shipment Received - ${message.shipmentId}`;

    check smtpClient->send(
        to = message.customerEmail,
        subject = subject,
        'from = smtpUsername,
        body = emailBody
    );

    log:printInfo("Sent shipment notification email",
            shipmentId = message.shipmentId,
            customerId = message.customerId,
            correlationId = correlationId
    );
}

function getCorelationId(map<byte[]|byte[][]|string|string[]> headers) returns string?|error {
    if !headers.hasKey("correlation-id") {
        return;
    }

    var headerValue = headers["correlation-id"];
    if headerValue is string {
        return headerValue;
    }

    if headerValue is byte[] {
        return string:fromBytes(headerValue);
    }
}

function getShipmentRecord(anydata messageValue) returns ShipmentMessage|error {
    if messageValue is byte[] {
        // Convert byte array to string first
        string jsonString = check string:fromBytes(messageValue);
        // Parse JSON string and convert to ShipmentMessage
        return jsonString.fromJsonStringWithType(ShipmentMessage);
    } else {
        // If it's already structured data, convert directly
        return messageValue.cloneWithType(ShipmentMessage);
    }
}
