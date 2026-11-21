import ballerina/http;

listener http:Listener httpListener = new (port = 8080);

service /payroll on httpListener {

    resource function post employees/[string id]/paytemplate/reimbursements(DetailedReimbursementTemplate[] templates)
            returns Reimbursement|error {
        ReimbursementTemplate[] reimbursementRequests = filterReimbursements(templates);
        Reimbursement result = check xero->/payrollxro/employees/[id]/paytemplate/reimbursements.post(reimbursementRequests);
        return result;
    }
}
