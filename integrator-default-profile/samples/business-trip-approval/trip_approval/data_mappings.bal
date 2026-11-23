isolated function toProfile(Employee employee) returns TravelerProfile => {
    employeeId: employee.employeeId,
    fullName: employee.fullName,
    grade: employee.grade,
    managerId: employee.managerId,
    costCenter: employee.costCenter
};

isolated function toApprovalView(PendingApproval approval) returns ApprovalView => {
    approvalId: approval.approvalId,
    requestedAt: approval.requestedAt,
    approverId: approval.approvalChain[approval.stage],
    stage: approval.stage + 1,
    stages: approval.approvalChain.length(),
    request: getRequest(approval.requestId)
};
