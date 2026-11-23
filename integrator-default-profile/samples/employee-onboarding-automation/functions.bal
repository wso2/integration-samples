import ballerina/ai;
import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

// ─── Phase 1 Tools ────────────────────────────────────────────────────────────

isolated function saveCandidateToSheets(string name, string email, string address,
        string jobTitle, string department, string salary, string bankingInfo) returns string|error {
    _ = check sheetsClient->appendValue(sheetsSpreadsheetId, [
        name, email, address, jobTitle, department, salary, bankingInfo, "no"
    ], {sheetName: sheetsTabName, startIndex: "A1"});
    log:printInfo("Candidate saved to Sheets", email = email);
    return string `Candidate ${name} saved to Google Sheets.`;
}

@ai:AgentTool {description: "Calls PDF API Hub to generate a personalized offer letter PDF. Saves it to a temporary file named offer_<candidateName>_<unique>.pdf and returns the file path."}
isolated function generateOfferLetterPDF(string name, string jobTitle, string department,
        string salary, string address) returns string|error {
    string html = string `<!DOCTYPE html>
        <html><head><style>
        body{font-family:Arial,sans-serif;max-width:700px;margin:60px auto;color:#333;line-height:1.6}
        h1{color:#1a3c5e;border-bottom:2px solid #1a3c5e;padding-bottom:8px}
        .field{margin:10px 0}.label{font-weight:bold}footer{margin-top:60px}
        </style></head><body>
        <h1>Offer Letter</h1>
        <p>Dear <strong>${htmlEscape(name)}</strong>,</p>
        <p>We are delighted to offer you the position of <strong>${htmlEscape(jobTitle)}</strong>
        in our <strong>${htmlEscape(department)}</strong> department.</p>
        <div class="field"><span class="label">Compensation:</span> ${htmlEscape(salary)}</div>
        <div class="field"><span class="label">Address on file:</span> ${htmlEscape(address)}</div>
        <p>Please reply to this email to confirm your acceptance within 5 business days.
        We look forward to welcoming you to our team.</p>
        <footer><p>Warm regards,<br/><strong>HR Team</strong></p></footer>
        </body></html>`;

    http:Request req = new;
    req.setJsonPayload({"html_content": html});
    req.setHeader("CLIENT-API-KEY", pdfApiHubKey);
    http:Response response = check pdfApiHubClient->post("/api/v1/generatePdf", req);
    if response.statusCode != 200 {
        string errBody = check response.getTextPayload();
        return error(string `PDF API Hub error (${response.statusCode}): ${errBody}`);
    }
    json respJson = check response.getJsonPayload();
    json|error pdfUrlJson = respJson.pdf_url;
    if pdfUrlJson is error {
        json|error errMsg = respJson.message;
        string detail = errMsg is json ? errMsg.toString() : "unknown error";
        return error(string `PDF API Hub error: ${detail}`);
    }
    string pdfUrl = pdfUrlJson.toString();
    if !pdfUrl.startsWith("https://") {
        return error(string `Unexpected PDF URL format: ${pdfUrl}`);
    }

    string[] parts = re`/`.split(pdfUrl);
    if parts.length() < 3 {
        return error(string `Cannot parse PDF URL: ${pdfUrl}`);
    }
    string baseUrl = string `${parts[0]}//${parts[2]}`;
    string urlPath = string `/${string:'join("/", ...parts.slice(3))}`;
    http:Client pdfDownloadClient = check new (baseUrl);
    http:Response pdfResp = check pdfDownloadClient->get(urlPath);
    if pdfResp.statusCode != 200 {
        return error(string `Failed to download PDF (${pdfResp.statusCode})`);
    }
    byte[] pdfBytes = check pdfResp.getBinaryPayload();
    string safeName = re`[^a-zA-Z0-9]`.replaceAll(name.toLowerAscii(), "_");
    string pdfPath = check file:createTemp(prefix = string `offer_${safeName}_`, suffix = ".pdf");
    check io:fileWriteBytes(pdfPath, pdfBytes);
    return pdfPath;
}

@ai:AgentTool {description: "Sends the offer letter PDF to the candidate via Gmail as an email attachment. pdfPath is the local file path returned by generateOfferLetterPDF. Deletes the local PDF after sending."}
isolated function sendOfferLetterEmail(string toEmail, string candidateName,
        string pdfPath) returns string|error {
    log:printInfo("Sending offer letter email", to = toEmail, pdfPath = pdfPath);
    gmail:MessageRequest msg = {
        to: [toEmail],
        subject: "Your Offer Letter",
        bodyInHtml: string `<p>Dear ${candidateName},</p>
<p>Congratulations! Please find your offer letter attached.</p>
<p>Kindly review and reply to this email to confirm your acceptance.</p>
<p>Regards,<br/>HR Team</p>`,
        attachments: [{
            mimeType: "application/pdf",
            name: "offer_letter.pdf",
            path: pdfPath
        }]
    };
    gmail:Message sent = check gmailClient->/users/me/messages/send.post(msg);
    log:printInfo("Offer letter sent", messageId = sent.id, to = toEmail);
    file:Error? removeErr = file:remove(pdfPath);
    if removeErr is file:Error {
        log:printWarn("Could not delete temp PDF", path = pdfPath, 'error = removeErr);
    }
    return string `Offer letter emailed to ${toEmail} (message id: ${sent.id}).`;
}

// ─── Phase 2 Functions ────────────────────────────────────────────────────────

isolated function fetchUnreadEmails() returns string|error {
    gmail:ListMessagesResponse messageList = check gmailClient->/users/me/messages(
        q = "label:INBOX is:unread subject:\"Re: Your Offer Letter\"",
        maxResults = 50
    );
    gmail:Message[] messages = messageList.messages ?: [];
    log:printInfo("Unread emails found", count = messages.length());
    if messages.length() == 0 {
        return "NO_UNREAD_EMAILS";
    }
    string[] lines = [];
    foreach gmail:Message msg in messages {
        gmail:Message full = check gmailClient->/users/me/messages/[msg.id](format = "full");
        string sender = full.'from ?: "";
        string subject = full.subject ?: "";
        string snippet = full.snippet ?: "";
        string cleanEmail = extractEmailAddress(sender);
        lines.push(string `${msg.id}|${cleanEmail}|${subject}|${snippet}`);
    }
    return string:'join("\n", ...lines);
}

isolated function lookupCandidateByEmail(string senderEmail) returns string|error {
    // Column layout: A=name B=email C=address D=jobTitle E=department F=salary G=bankingInfo H=status
    sheets:Column emailColumn = check sheetsClient->getColumn(
        sheetsSpreadsheetId, sheetsTabName, "B"
    );
    (int|string|decimal)[] emails = emailColumn.values;
    foreach int i in 0 ..< emails.length() {
        if emails[i].toString().trim().toLowerAscii() == senderEmail.trim().toLowerAscii() {
            int rowIndex = i + 1;
            sheets:Row row = check sheetsClient->getRow(
                sheetsSpreadsheetId, sheetsTabName, rowIndex
            );
            (int|string|decimal)[] cells = row.values;
            string status = cells.length() >= 8 ? cells[7].toString() : "no";
            if status == "yes" || status == "in_progress" {
                return "ALREADY_PROVISIONED";
            }
            string candidateName = cells.length() >= 1 ? cells[0].toString() : "Unknown";
            return string `${rowIndex}|${candidateName}`;
        }
    }
    return "NOT_FOUND";
}

isolated function classifyEmailAcceptance(string subject, string bodySnippet) returns string|error {
    string prompt = string `Classify this email reply to a job offer:
Subject: ${subject}
Body: ${bodySnippet}

Is the candidate accepting the offer? Consider negations — phrases like "I cannot accept",
"I do not accept", or "I decline" mean NO. Reply with ONLY the single word YES or NO.`;
    string result = check emailClassifierAgent.run(prompt);
    return result.trim().toLowerAscii().startsWith("yes") ? "YES" : "NO";
}

isolated function createWorkspaceAccount(string candidateName,
        string candidateEmail) returns string|error {
    string[] nameParts = re` `.split(candidateName.trim());
    string sanitizedFirst = re`[^a-z0-9]`.replaceAll(nameParts[0].toLowerAscii(), "");
    string rawLast = nameParts.length() > 1 ? nameParts[nameParts.length() - 1] : nameParts[0];
    string sanitizedLast = re`[^a-z0-9]`.replaceAll(rawLast.toLowerAscii(), "");
    if sanitizedFirst == "" || sanitizedLast == "" {
        return error("Cannot derive username: name must contain valid alphanumeric characters for first and last name");
    }

    string workEmail = "";
    foreach int i in 0 ..< 10 {
        string candidate = i == 0
            ? string `${sanitizedFirst}.${sanitizedLast}`
            : string `${sanitizedFirst}.${sanitizedLast}${i}`;
        string tryEmail = string `${candidate}@${workspaceDomain}`;
        json requestBody = {
            "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User", "urn:scim:wso2:schema"],
            "userName": string `DEFAULT/${tryEmail}`,
            "name": {
                "givenName": sanitizedFirst,
                "familyName": sanitizedLast
            },
            "emails": [{"type": "work", "value": tryEmail, "primary": true}],
            "urn:scim:wso2:schema": {"askPassword": "true"}
        };
        http:Response response = check wso2IsClient->post("/scim2/Users", requestBody);
        if response.statusCode == 201 {
            workEmail = tryEmail;
            break;
        }
        if response.statusCode == 409 {
            if i == 9 {
                return error(string `Could not find a unique username for ${candidateName} after 10 attempts`);
            }
            continue;
        }
        string errBody = check response.getTextPayload();
        return error(string `Asgardeo SCIM error (${response.statusCode}): ${errBody}`);
    }
    log:printInfo("Asgardeo account created", workEmail = workEmail);
    return workEmail;
}

isolated function sendCredentialsEmail(string toEmail, string candidateName,
        string workEmail) returns string|error {
    gmail:MessageRequest msg = {
        to: [toEmail],
        subject: "Welcome! Your Work Account Details",
        bodyInHtml: string `<p>Dear ${candidateName},</p>
            <p>Welcome to the team! Your work account has been created in Asgardeo.</p>
            <ul>
            <li><strong>Work Email:</strong> ${workEmail}</li>
            </ul>
            <p>You will receive a separate email from Asgardeo with a link to set your password.</p>
            <p>Regards,<br/>IT Team</p>`
    };
    gmail:Message sent = check gmailClient->/users/me/messages/send.post(msg);
    log:printInfo("Welcome email sent", messageId = sent.id, to = toEmail);
    return string `Welcome email sent to ${toEmail}.`;
}

isolated function markCandidateProvisioned(string rowNumber) returns string|error {
    check sheetsClient->setCell(
        sheetsSpreadsheetId, sheetsTabName, string `H${rowNumber}`, "yes"
    );
    log:printInfo("Marked as provisioned", row = rowNumber);
    return string `Row ${rowNumber} marked as provisioned.`;
}

isolated function markCandidateInProgress(string rowNumber) returns string|error {
    check sheetsClient->setCell(
        sheetsSpreadsheetId, sheetsTabName, string `H${rowNumber}`, "in_progress"
    );
    log:printInfo("Marked as in_progress", row = rowNumber);
    return string `Row ${rowNumber} marked as in_progress.`;
}

isolated function markEmailAsRead(string messageId) returns error? {
    gmail:ModifyMessageRequest modifyReq = {removeLabelIds: ["UNREAD"]};
    _ = check gmailClient->/users/me/messages/[messageId]/modify.post(modifyReq);
    log:printInfo("Marked email as read", messageId = messageId);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

isolated function extractEmailAddress(string raw) returns string {
    int? ltIdx = raw.indexOf("<");
    int? gtIdx = raw.indexOf(">");
    if ltIdx is int && gtIdx is int && gtIdx > ltIdx {
        return raw.substring(ltIdx + 1, gtIdx).trim();
    }
    return raw.trim();
}

isolated function htmlEscape(string text) returns string {
    string result = re`&`.replaceAll(text, "&amp;");
    result = re`<`.replaceAll(result, "&lt;");
    result = re`>`.replaceAll(result, "&gt;");
    result = re`"`.replaceAll(result, "&quot;");
    return result;
}
