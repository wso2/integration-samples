function filterReimbursements(DetailedReimbursementTemplate[] templates) returns ReimbursementTemplate[] =>
    from var templatesItem in templates
select {reimbursementTypeID: templatesItem.reimbursementTypeID, fixedAmount: templatesItem.fixedAmount};
