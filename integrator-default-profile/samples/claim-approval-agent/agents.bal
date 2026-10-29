import ballerina/workflow;

final workflow:DurableAgent claimAgent = check new ({
    systemPrompt: {
        role: "Expense claim assistant",
        instructions: string `You handle one employee expense claim. Your input carries the claim id, the employee, the description and the amount.
1. Decide whether the description reads as a business expense. Personal items, gifts, family costs and alcohol are not business expenses.
2. Call checkPolicy with the claim id and your judgment as businessExpense. Approval is needed when checkPolicy says so.
3. If approval is needed, call approveClaim with the claim id, employee, description and amount from your input, and the reason from checkPolicy. If the approver approves, call payClaim with the claim id and the approver's comment. If not, call notifyRejection with the claim id and the approver's comment.
4. If approval is not needed, call payClaim with the claim id and an empty comment.
5. Finish with a one-line summary that says whether the claim was paid or rejected, and whether a person approved it.`
    },
    model: wso2ModelProvider,
    inputType: ClaimInput,
    activities: [checkPolicy, payClaim, notifyRejection],
    humanTasks: {
        approveClaim: {
            userRoles: approverRole,
            title: "Approve expense claim",
            description: "Asks an approver to decide on the claim, and waits for the decision.",
            taskInputType: ApprovalRequest,
            resultType: Decision
        }
    }
});
