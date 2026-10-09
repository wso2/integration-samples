import ballerina/edi;
import ballerina/io;
import ballerina/log;

import wso2/orders;

configurable string ediFilePath = "../orders.edi";
configurable string tradingPartner = "SUPERMART";

public function main() returns error? {
    do {
        // The envelope carries the sender, and needs no schema to read. Only the first
        // 512 characters of the file are read.
        edi:EdifactHeaders headers = check edi:edifactHeadersFromEdiFile(ediFilePath);
        if headers.unb.sender.id != tradingPartner {
            log:printInfo(string `Unknown partner: ${headers.unb.sender.id}`);
            return;
        }
        log:printInfo(string `Order file from ${headers.unb.sender.id}, reference ${headers.unb.controlRef}`);

        // Reading the orders themselves needs the schema. Envelope segments are
        // fail-fast; transaction bodies are fail-safe.
        string ediContent = check io:fileReadString(ediFilePath);
        orders:ORDERSInterchange interchange = check orders:interchangeFromEdiString(ediContent);

        foreach orders:ORDERSTransaction txn in interchange.transactions {
            string messageRef = txn.transactionHeader.Message_header.message_reference_number;
            orders:ORDERS|error body = txn.body;
            if body is error {
                // Quarantine: this message could not be read, the rest still can.
                log:printError("Quarantined message", 'error = body, reference = messageRef);
                continue;
            }
            string orderId = body.Beginning_of_message?.DOCUMENT_MESSAGE_IDENTIFICATION?.Document_identifier ?: "";
            log:printInfo(string `Order ${orderId} received from ${headers.unb.sender.id}`);
        }
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
