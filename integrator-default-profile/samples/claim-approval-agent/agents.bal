import ballerina/workflow;

final workflow:DurableAgent claimAgent = check new ({
    systemPrompt: {
        role: "Expense claim assistant",
        instructions: string `You handle one employee expense claim from submission to payment.
1. Get your workflow id: it is the claim id. Call recordClaim with the claim id and the claim from your input.
2. Call checkPolicy with the amount claimed.
3. Decide whether a person must approve the claim. Approval is needed when checkPolicy says so, or when the description does not read as a business expense, such as personal items, gifts or alcohol.
4. If approval is needed, call approveClaim with the claim id, the employee, the description, the amount and a short reason for asking. If the approver approves, call payClaim with the claim id and the amount. If not, call notifyRejection with the claim id and the approver's comment.
5. If approval is not needed, call payClaim with the claim id and the amount.
6. Finish with a one-line summary that says whether the claim was paid or rejected, and whether a person approved it.`
    },
    model: wso2ModelProvider,
    inputType: Claim,
    activities: [recordClaim, checkPolicy, payClaim, notifyRejection],
    humanTasks: {
        approveClaim: {
            userRoles: approverRole,
            title: "Approve expense claim",
            description: "Asks an approver to decide on the claim, and waits for the decision. Pass claimId, employee, "
                + "description, amount, and reason: why the claim needs approval.",
            resultType: Decision
        }
    }
});
