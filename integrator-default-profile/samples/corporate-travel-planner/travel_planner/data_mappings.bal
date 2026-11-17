import wso2/logistics_coordinator;

isolated function toProfile(Employee employee) returns TravelerProfile => {
    employeeId: employee.employeeId,
    fullName: string `${employee.givenName} ${employee.familyName}`,
    grade: employee.grade,
    homeAirport: employee.homeAirport,
    managerId: employee.managerId,
    costCenter: employee.costCenter
};

isolated function toPassengerDetails(Employee employee) returns logistics_coordinator:PassengerDetails => {
    givenName: employee.givenName,
    familyName: employee.familyName,
    title: employee.title,
    gender: employee.gender,
    bornOn: employee.bornOn,
    email: employee.email,
    phoneNumber: employee.phoneNumber
};

isolated function toApprovalView(PendingApproval approval) returns ApprovalView => {
    approvalId: approval.approvalId,
    requestedAt: approval.requestedAt,
    proposal: getProposal(approval.proposalId)
};
