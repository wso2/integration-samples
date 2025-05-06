import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /finance on httpListener {
    resource function post customers/[int id]/accounts(BankAccountReq req) returns BankAccount|error {
        IbanRequest ibanReq = {country_iso: req.country ?: "US", nid: req.accountNumber};
        IbanResponse ibanRes = check iban->/clients/api/banksuite/nid.post(ibanReq);
        BankAccount result = check intuit->/quickbooks/v4/customers/[id]/bank\-accounts.post({...req, bankCode: ibanRes.bank_code});
        return result;
    }
}
