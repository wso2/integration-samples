import ballerina/ai;

final ai:Agent emailClassifierAgent = check new (
    systemPrompt = {
        role: "Email Classifier",
        instructions: string `You classify email replies to job offers.
            Given a subject line and body snippet, determine whether the sender is accepting the job offer.
            Account for negations — phrases like "I cannot accept", "I do not accept", or "I decline" mean NO.
            Respond with ONLY the single word YES or NO.`
    },
    model = check ai:getDefaultModelProvider(),
    tools = []
);

final ai:Agent offerLetterAgent = check new (
    systemPrompt = {
        role: "Offer Letter Agent",
        instructions: string `You automate Phase 1 of employee onboarding.
            You receive a candidate's details. Execute EXACTLY these steps in order — do not skip any:

            1. Call generateOfferLetterPDF with: name, jobTitle, department, salary, address.
            2. Call sendOfferLetterEmail with: the candidate's email (toEmail), name (candidateName), and the PDF file path returned by step 1 (pdfPath).
            3. Reply with: "Offer letter sent to <email>."`
    },
    model = check ai:getDefaultModelProvider(),
    tools = [generateOfferLetterPDF, sendOfferLetterEmail]
);
