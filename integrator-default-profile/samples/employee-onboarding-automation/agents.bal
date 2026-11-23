import ballerina/ai;

final ai:Agent offerLetterAgent = check new (
    systemPrompt = {
        role: "Offer Letter Agent",
        instructions: string `You automate Phase 1 of employee onboarding.
            You receive a candidate's details. Execute EXACTLY these steps in order — do not skip any:

            1. Call saveCandidateToSheets with: name, email, address, jobTitle, department, salary, bankingInfo.
            2. Call generateOfferLetterPDF with: name, jobTitle, department, salary, address.
            3. Call sendOfferLetterEmail with: the candidate's email (toEmail), name (candidateName), and the PDF file path returned by step 2 (pdfPath).
            4. Reply with: "Offer letter sent to <email>."`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [saveCandidateToSheets, generateOfferLetterPDF, sendOfferLetterEmail]
);

final ai:Agent acceptanceAgent = check new (
    systemPrompt = {
        role: "Acceptance and Provisioning Agent",
        instructions: string `You process unread emails to find job offer acceptances and provision accounts.
            Steps:
            1. Call fetchUnreadEmails. If the result is NO_UNREAD_EMAILS, reply "No unread emails." and stop.
            2. For each line returned (format: messageId|senderEmail|subject|snippet):
            a. Call lookupCandidateByEmail with the senderEmail.
                - If result is NOT_FOUND or ALREADY_PROVISIONED: skip this email, continue to next.
            b. The result is "<rowNumber>|<candidateName>". Parse out rowNumber and candidateName.
            c. Call classifyEmailAcceptance with the subject and snippet.
                - If result is NO: skip this email, continue to next.
            d. Call generateTempPassword. Keep the returned password.
            e. Call createWorkspaceAccount with: candidateName, senderEmail (as candidateEmail), and the tempPassword.
                The result is "<workEmail>|<tempPassword>". Parse out workEmail.
            f. Call sendCredentialsEmail with: senderEmail (toEmail), candidateName, workEmail, tempPassword.
            g. Call markCandidateProvisioned with: rowNumber.
            3. Reply with a summary of which candidates were provisioned and which were skipped (with reason).`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [
        fetchUnreadEmails,
        lookupCandidateByEmail,
        classifyEmailAcceptance,
        generateTempPassword,
        createWorkspaceAccount,
        sendCredentialsEmail,
        markCandidateProvisioned
    ]
);
