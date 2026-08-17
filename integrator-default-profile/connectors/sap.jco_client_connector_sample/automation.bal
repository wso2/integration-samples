import ballerina/log;

public function main() returns error? {
    do {
        check jcoClient->sendIDoc(xml `<IDOC><EDI_DC40 SEGMENT="1"><TABNAM>EDI_DC40</TABNAM><DOCNUM>0000000000000001</DOCNUM><IDOCTYP>ORDERS05</IDOCTYP><MESTYP>ORDERS</MESTYP></EDI_DC40></IDOC>`);
        xml executeResult = check jcoClient->execute("STFC_CONNECTION", {importParameters: {"REQUTEXT": "Hello SAP"}});
        log:printInfo("RFC execute result", result = executeResult);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
