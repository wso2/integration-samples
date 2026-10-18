import ballerina/edi;
import ballerina/ftp;
import ballerina/log;

import supplier/orders;

listener ftp:Listener ftpListener = new (host = "localhost", protocol = ftp:SFTP, port = 2222, auth = {credentials: {username: string `${sftpUsername}`, password: string `${sftpPassword}`}});

@ftp:ServiceConfig {path: "/edi/inbox"}
service ftp:Service on ftpListener {
    @ftp:FunctionConfig {afterProcess: {moveTo: "/edi/processed"}, afterError: {moveTo: "/edi/rejected"}}
    remote function onFile(byte[] content, ftp:FileInfo fileInfo) returns error? {
        do {
            string ediText = check string:fromBytes(content);
            edi:EdifactHeaders headers = check edi:edifactHeadersFromEdiString(ediText);
            if headers.unb.sender.id != tradingPartner {
                return error(string `Unknown trading partner: ${headers.unb.sender.id}`);
            }
            log:printInfo(string `Order file from ${headers.unb.sender.id}, reference ${headers.unb.controlRef}`);
            orders:ORDERSInterchange interchange = check orders:interchangeFromEdiString(ediText);
            foreach orders:ORDERSTransaction txn in interchange.transactions {
                orders:ORDERS|error body = txn.body;
                if body is error {
                    log:printError("Quarantined message", body, reference = txn.transactionHeader.Message_header.message_reference_number);
                    continue;
                }
                string orderId = body.Beginning_of_message?.DOCUMENT_MESSAGE_IDENTIFICATION?.Document_identifier ?: "";
                log:printInfo(string `Order ${orderId} received from ${headers.unb.sender.id}`);
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }

}
