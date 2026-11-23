import ballerina/ai;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/random;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

// ─── Phase 1 Tools ────────────────────────────────────────────────────────────

@ai:AgentTool {description: "Saves a candidate record to Google Sheets with status set to no."}
isolated function saveCandidateToSheets(string name, string email, string address,
        string jobTitle, string department, string salary, string bankingInfo) returns string|error {
    _ = check sheetsClient->appendValue(sheetsSpreadsheetId, [
        name, email, address, jobTitle, department, salary, bankingInfo, "no"
    ], {sheetName: sheetsTabName, startIndex: "A1"});
    log:printInfo("Candidate saved to Sheets", email = email);
    return string `Candidate ${name} saved to Google Sheets.`;
}

@ai:AgentTool {description: "Calls PDF API Hub to generate a personalized offer letter PDF. Saves it to /tmp/offer_letter.pdf and returns the file path."}
isolated function generateOfferLetterPDF(string name, string jobTitle, string department,
        string salary, string address) returns string|error {
    string html = string `<!DOCTYPE html>
<html><head><style>
body{font-family:Arial,sans-serif;max-width:700px;margin:60px auto;color:#333;line-height:1.6}
h1{color:#1a3c5e;border-bottom:2px solid #1a3c5e;padding-bottom:8px}
.field{margin:10px 0}.label{font-weight:bold}footer{margin-top:60px}
</style></head><body>
<h1>Offer Letter</h1>
<p>Dear <strong>${name}</strong>,</p>
<p>We are delighted to offer you the position of <strong>${jobTitle}</strong>
in our <strong>${department}</strong> department.</p>
<div class="field"><span class="label">Compensation:</span> ${salary}</div>
<div class="field"><span class="label">Address on file:</span> ${address}</div>
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

    string[] parts = re`/`.split(pdfUrl);
    string baseUrl = string `${parts[0]}//${parts[2]}`;
    string urlPath = string `/${string:'join("/", ...parts.slice(3))}`;
    http:Client pdfDownloadClient = check new (baseUrl);
    http:Response pdfResp = check pdfDownloadClient->get(urlPath);
    if pdfResp.statusCode != 200 {
        return error(string `Failed to download PDF (${pdfResp.statusCode})`);
    }
    byte[] pdfBytes = check pdfResp.getBinaryPayload();
    string safeName = re`[^a-zA-Z0-9]`.replaceAll(name.toLowerAscii(), "_");
    string pdfPath = string `/tmp/offer_letter_${safeName}.pdf`;
    check io:fileWriteBytes(pdfPath, pdfBytes);
    return pdfPath;
}

@ai:AgentTool {description: "Sends the offer letter PDF to the candidate via Gmail as an email attachment. pdfPath is the local file path returned by generateOfferLetterPDF."}
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
    return string `Offer letter emailed to ${toEmail} (message id: ${sent.id}).`;
}

// ─── Phase 2 Tools ────────────────────────────────────────────────────────────

@ai:AgentTool {description: "Fetches unread emails from the Gmail inbox. Returns one line per email in the format: messageId|senderEmail|subject|snippet"}
isolated function fetchUnreadEmails() returns string|error {
    gmail:ListMessagesResponse messageList = check gmailClient->/users/me/messages(
        q = "label:INBOX is:unread subject:\"Re: Your Offer Letter\"",
        maxResults = 10
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

@ai:AgentTool {description: "Looks up a candidate in Google Sheets by their personal email. Returns rowNumber|candidateName if found and not provisioned, NOT_FOUND if absent, or ALREADY_PROVISIONED if already onboarded."}
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
            if status == "yes" {
                return "ALREADY_PROVISIONED";
            }
            string candidateName = cells.length() >= 1 ? cells[0].toString() : "Unknown";
            return string `${rowIndex}|${candidateName}`;
        }
    }
    return "NOT_FOUND";
}

@ai:AgentTool {description: "Determines whether an email is a job offer acceptance using keyword matching. Returns YES for a clear acceptance, NO for anything else."}
isolated function classifyEmailAcceptance(string subject, string bodySnippet) returns string|error {
    string combined = (subject + " " + bodySnippet).toLowerAscii();
    string[] acceptKeywords = ["i accept", "i am accepting", "happy to accept", "pleased to accept",
                               "glad to accept", "yes, i accept", "yes i accept", "confirm my acceptance",
                               "accept the offer", "accepting the offer", "looking forward to joining",
                               "excited to join", "happy to join", "i agree"];
    foreach string kw in acceptKeywords {
        if combined.includes(kw) {
            return "YES";
        }
    }
    return "NO";
}

@ai:AgentTool {description: "Generates a cryptographically random 16-character temporary password."}
isolated function generateTempPassword() returns string|error {
    string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
    int charsLen = chars.length();
    string[] parts = [];
    foreach int _ in 0 ..< 16 {
        int idx = check random:createIntInRange(0, charsLen);
        parts.push(chars.substring(idx, idx + 1));
    }
    return string:'join("", ...parts);
}

@ai:AgentTool {description: "Creates a new user account in WSO2 Identity Server via SCIM 2.0. Returns workEmail|tempPassword on success."}
isolated function createWorkspaceAccount(string candidateName,
        string candidateEmail, string tempPassword) returns string|error {
    string[] nameParts = re` `.split(candidateName.trim().toLowerAscii());
    string firstName = nameParts[0];
    string lastName = nameParts.length() > 1 ? nameParts[nameParts.length() - 1] : firstName;
    string username = string `${firstName}.${lastName}`;
    string workEmail = string `${username}@${workspaceDomain}`;

    json requestBody = {
        "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
        "userName": string `DEFAULT/${workEmail}`,
        "password": tempPassword,
        "name": {
            "givenName": firstName,
            "familyName": lastName
        },
        "emails": [{"type": "work", "value": workEmail, "primary": true}]
    };
    http:Response response = check wso2IsClient->post("/scim2/Users", requestBody);
    if response.statusCode != 201 {
        string errBody = check response.getTextPayload();
        return error(string `WSO2 IS SCIM error (${response.statusCode}): ${errBody}`);
    }
    log:printInfo("WSO2 IS account created", workEmail = workEmail);
    return string `${workEmail}|${tempPassword}`;
}

@ai:AgentTool {description: "Sends Google Workspace credentials to the new employee via Gmail."}
isolated function sendCredentialsEmail(string toEmail, string candidateName,
        string workEmail, string tempPassword) returns string|error {
    gmail:MessageRequest msg = {
        to: [toEmail],
        subject: "Welcome! Your Work Account Details",
        bodyInHtml: string `<p>Dear ${candidateName},</p>
<p>Welcome to the team! Your work account has been created in WSO2 Identity Server.</p>
<ul>
  <li><strong>Work Email:</strong> ${workEmail}</li>
  <li><strong>Temporary Password:</strong> ${tempPassword}</li>
</ul>
<p>Please sign in and change your password on first login.</p>
<p>Regards,<br/>IT Team</p>`
    };
    gmail:Message sent = check gmailClient->/users/me/messages/send.post(msg);
    log:printInfo("Credentials sent", messageId = sent.id, to = toEmail);
    return string `Credentials emailed to ${toEmail}.`;
}

@ai:AgentTool {description: "Sets the provisioning status to yes for the given row in Google Sheets."}
isolated function markCandidateProvisioned(string rowNumber) returns string|error {
    check sheetsClient->setCell(
        sheetsSpreadsheetId, sheetsTabName, string `H${rowNumber}`, "yes"
    );
    log:printInfo("Marked as provisioned", row = rowNumber);
    return string `Row ${rowNumber} marked as provisioned.`;
}

// ─── Helper ───────────────────────────────────────────────────────────────────

# Extracts a plain email address from a "Display Name <email@example.com>" string.
isolated function extractEmailAddress(string raw) returns string {
    int? ltIdx = raw.indexOf("<");
    int? gtIdx = raw.indexOf(">");
    if ltIdx is int && gtIdx is int && gtIdx > ltIdx {
        return raw.substring(ltIdx + 1, gtIdx).trim();
    }
    return raw.trim();
}
