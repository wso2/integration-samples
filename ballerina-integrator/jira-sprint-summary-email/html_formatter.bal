import ballerina/time;

// HTML email formatting functions

// Escape HTML special characters to prevent XSS and markup breakage
function escapeHtml(string text) returns string {
    string:RegExp ampersand = re `&`;
    string:RegExp lessThan = re `<`;
    string:RegExp greaterThan = re `>`;
    string:RegExp doubleQuote = re `"`;
    string:RegExp singleQuote = re `'`;
    
    string escaped = text;
    escaped = ampersand.replaceAll(escaped, "&amp;");
    escaped = lessThan.replaceAll(escaped, "&lt;");
    escaped = greaterThan.replaceAll(escaped, "&gt;");
    escaped = doubleQuote.replaceAll(escaped, "&quot;");
    escaped = singleQuote.replaceAll(escaped, "&#x27;");
    return escaped;
}

function formatEmailSubject(SprintSummary summary) returns string {
    string:RegExp sprintNamePattern = re `\{\{sprintName\}\}`;
    string:RegExp sprintIdPattern = re `\{\{sprintId\}\}`;
    
    string subject = emailSubjectTemplate;
    // Note: Email subjects don't need HTML escaping, but we escape for safety
    subject = sprintNamePattern.replaceAll(subject, escapeHtml(summary.sprintName));
    subject = sprintIdPattern.replaceAll(subject, summary.sprintId.toString());
    return subject;
}

function formatEmailBody(SprintSummary summary) returns string {
    string formattedTime = getFormattedTimeStamp(time:utcNow());

    string htmlBody = string `
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="x-apple-disable-message-reformatting">
        <title>Jira Sprint Summary</title>
        <style type="text/css">
            table, td { border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
            img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; }
            body { height: 100% !important; margin: 0 !important; padding: 0 !important; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; -webkit-text-size-adjust: 100%; }

            @media screen and (max-width: 600px) {
                .email-container { width: 100% !important; margin: auto !important; }
                .stack-column, .stack-column-center { display: block !important; width: 100% !important; max-width: 100% !important; direction: ltr !important; }
                .stack-column-center { text-align: center !important; }
                .center-on-mobile { text-align: center !important; }
                .mobile-pad { padding-left: 20px !important; padding-right: 20px !important; }
                .hide-on-mobile { display: none !important; }
            }
        </style>
    </head>
    <body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #f4f5f7;">
        <center style="width: 100%; background-color: #f4f5f7;">

            <div style="display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;">
                Sprint Summary for ${escapeHtml(summary.sprintName)}: ${summary.totalIssues} Total, ${summary.completedIssues} Completed, ${summary.carriedOverIssues} Carried Over
            </div>

            <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="margin: auto;" class="email-container">

                <tr><td height="40" style="font-size: 0; line-height: 0;">&nbsp;</td></tr>

                <tr>
                    <td style="background-color: #0052CC; padding: 30px; border-radius: 6px 6px 0 0; text-align: left;">
                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                            <tr>
                                <td style="font-family: sans-serif; font-size: 20px; font-weight: 600; color: #ffffff; line-height: 24px;">
                                    ${escapeHtml(summary.sprintName)}
                                    <div style="font-size: 14px; color: #deebff; font-weight: 400; margin-top: 5px;">Sprint ID: ${summary.sprintId} • ${formattedTime}</div>
                                    <div style="font-size: 14px; color: #deebff; font-weight: 400; margin-top: 5px;">Completed: ${escapeHtml(summary.completedDate)}</div>
                                </td>
                                <td width="60" align="right" valign="middle">
                                    <img src="https://wac-cdn.atlassian.com/assets/img/favicons/atlassian/apple-touch-icon-152x152.png" width="48" height="48" alt="Jira" style="display: block; border: 0; border-radius: 6px;">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr>
                    <td style="background-color: #ffffff; padding: 20px 0; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6;">
                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                            <tr>
                                <td width="33%" align="center" valign="top" style="font-family: sans-serif;">
                                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                        <tr><td align="center" style="font-size: 24px; font-weight: bold; color: #172b4d;">${summary.totalIssues}</td></tr>
                                        <tr><td align="center" style="font-size: 11px; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Total</td></tr>
                                    </table>
                                </td>
                                <td width="33%" align="center" valign="top" style="font-family: sans-serif; border-left: 1px solid #eeeeee; border-right: 1px solid #eeeeee;">
                                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                        <tr><td align="center" style="font-size: 24px; font-weight: bold; color: #00875a;">${summary.completedIssues}</td></tr>
                                        <tr><td align="center" style="font-size: 11px; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Completed</td></tr>
                                    </table>
                                </td>
                                <td width="33%" align="center" valign="top" style="font-family: sans-serif;">
                                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                        <tr><td align="center" style="font-size: 24px; font-weight: bold; color: #de350b;">${summary.carriedOverIssues}</td></tr>
                                        <tr><td align="center" style="font-size: 11px; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Carried Over</td></tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                ${includeCompletedIssues ? getHtmlFormattedIssues(summary.completedIssuesList, "Completed", "#00875a") : ""}
                ${includeCarriedOverIssues ? getHtmlFormattedIssues(summary.carriedOverIssuesList, "Carried Over", "#de350b") : ""}
                ${includeAssigneeBreakdown ? getHtmlFormattedAssigneeBreakdown(summary.assigneeBreakdown) : ""}
                ${includeMidSprintAdditions ? getHtmlFormattedMidSprintAdditions(summary.midSprintAdditions) : ""}

                <tr>
                    <td style="padding: 30px; text-align: center; font-family: sans-serif; font-size: 12px; color: #5e6c84; line-height: 18px;">
                        <p style="margin: 0;">You are receiving this sprint summary for <strong>${escapeHtml(summary.sprintName)}</strong>.</p>
                    </td>
                </tr>

                <tr><td height="40" style="font-size: 0; line-height: 0;">&nbsp;</td></tr>
            </table>

        </center>
    </body>
    </html>
    `;

    return htmlBody;
}

function getHtmlFormattedIssues(IssueDetails[] issues, string section, string iconColor) returns string {
    string formattedIssues = "";
    if issues.length() == 0 {
        return formattedIssues;
    }

    formattedIssues += string `
        <tr>
            <td style="background-color: #ffffff; padding: 20px 30px 10px 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #172b4d;">
                ${section} Issues
            </td>
        </tr>
        <tr>
            <td style="background-color: #ffffff; padding: 0 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6;" class="mobile-pad">
    `;

    foreach IssueDetails issue in issues {
        string assignee = issue.assignee ?: "Unassigned";
        formattedIssues += string `
            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border-bottom: 1px solid #dfe1e6;">
                <tr>
                    <td valign="top" width="24" style="padding: 24px 10px 24px 0;">
                        <span style="color: ${iconColor}; font-size: 20px;">◎</span>
                    </td>
                    <td valign="middle" style="padding: 24px 0; font-family: sans-serif;">
                        <div style="text-decoration: none; color: #172b4d; font-size: 16px; font-weight: 600; line-height: 20px;">${escapeHtml(issue.summary)}</div>
                        <div style="font-size: 12px; color: #5e6c84; margin-top: 4px; line-height: 18px;">
                            ${escapeHtml(issue.key)} • ${escapeHtml(issue.status)} • Assignee: <span style="color: #172b4d;">${escapeHtml(assignee)}</span>
                        </div>
                    </td>
                </tr>
            </table>
        `;
    }

    formattedIssues += string `
            </td>
        </tr>
    `;
    return formattedIssues;
}

function getHtmlFormattedAssigneeBreakdown(AssigneeStats[] breakdown) returns string {
    if breakdown.length() == 0 {
        return "";
    }

    string formattedBreakdown = string `
        <tr>
            <td style="background-color: #ffffff; padding: 20px 30px 10px 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #172b4d;">
                Team Contributions
            </td>
        </tr>
        <tr>
            <td style="background-color: #ffffff; padding: 0 30px 20px 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6; border-bottom: 1px solid #dfe1e6;" class="mobile-pad">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border: 1px solid #dfe1e6; border-radius: 3px;">
                    <tr style="background-color: #f4f5f7;">
                        <td style="padding: 12px 16px; font-family: sans-serif; font-size: 12px; font-weight: 600; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #dfe1e6;">
                            Team Member
                        </td>
                        <td align="center" style="padding: 12px 16px; font-family: sans-serif; font-size: 12px; font-weight: 600; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            Completed
                        </td>
                        <td align="center" style="padding: 12px 16px; font-family: sans-serif; font-size: 12px; font-weight: 600; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            Carried Over
                        </td>
                        <td align="center" style="padding: 12px 16px; font-family: sans-serif; font-size: 12px; font-weight: 600; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            Total
                        </td>
                    </tr>
    `;

    foreach AssigneeStats stats in breakdown {
        decimal completionRate = 0;
        if stats.totalCount > 0 {
            completionRate = (<decimal>stats.completedCount / <decimal>stats.totalCount) * 100;
        }
        
        string rateString = completionRate.toString();
        int maxLength = rateString.length() < 5 ? rateString.length() : 5;
        string completionRateText = string `${rateString.substring(0, maxLength)}%`;
        string progressBarColor = completionRate >= 75d ? "#00875a" : (completionRate >= 50d ? "#ff991f" : "#de350b");

        formattedBreakdown += string `
                    <tr>
                        <td style="padding: 16px; font-family: sans-serif; font-size: 14px; color: #172b4d; border-bottom: 1px solid #dfe1e6;">
                            <div style="font-weight: 600; margin-bottom: 4px;">${escapeHtml(stats.assigneeName)}</div>
                            <div style="background-color: #f4f5f7; height: 6px; border-radius: 3px; overflow: hidden;">
                                <div style="background-color: ${progressBarColor}; height: 6px; width: ${completionRateText};"></div>
                            </div>
                        </td>
                        <td align="center" style="padding: 16px; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #00875a; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            ${stats.completedCount}
                        </td>
                        <td align="center" style="padding: 16px; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #de350b; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            ${stats.carriedOverCount}
                        </td>
                        <td align="center" style="padding: 16px; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #172b4d; border-bottom: 1px solid #dfe1e6; border-left: 1px solid #dfe1e6;">
                            ${stats.totalCount}
                        </td>
                    </tr>
        `;
    }

    formattedBreakdown += string `
                </table>
            </td>
        </tr>
    `;

    return formattedBreakdown;
}

function getHtmlFormattedMidSprintAdditions(IssueDetails[] issues) returns string {
    if issues.length() == 0 {
        return "";
    }

    string formattedAdditions = string `
        <tr>
            <td style="background-color: #ffffff; padding: 20px 30px 10px 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6; font-family: sans-serif; font-size: 16px; font-weight: 600; color: #172b4d;">
                Mid-Sprint Additions
                <div style="font-size: 12px; color: #5e6c84; font-weight: 400; margin-top: 4px;">Issues added after sprint started</div>
            </td>
        </tr>
        <tr>
            <td style="background-color: #ffffff; padding: 0 30px 20px 30px; border-left: 1px solid #dfe1e6; border-right: 1px solid #dfe1e6; border-bottom: 1px solid #dfe1e6;" class="mobile-pad">
    `;

    foreach IssueDetails issue in issues {
        string assignee = issue.assignee ?: "Unassigned";
        string createdDate = "N/A";
        if issue.created is string {
            string createdValue = <string>issue.created;
            time:Utc|error parsedTime = time:utcFromString(createdValue);
            if parsedTime is time:Utc {
                createdDate = getFormattedTimeStamp(parsedTime);
            }
        }

        formattedAdditions += string `
            <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border-bottom: 1px solid #dfe1e6;">
                <tr>
                    <td valign="top" width="24" style="padding: 24px 10px 24px 0;">
                        <span style="color: #ff991f; font-size: 20px;">⚠</span>
                    </td>
                    <td valign="middle" style="padding: 24px 0; font-family: sans-serif;">
                        <div style="text-decoration: none; color: #172b4d; font-size: 16px; font-weight: 600; line-height: 20px;">${escapeHtml(issue.summary)}</div>
                        <div style="font-size: 12px; color: #5e6c84; margin-top: 4px; line-height: 18px;">
                            ${escapeHtml(issue.key)} • ${escapeHtml(issue.status)} • Assignee: <span style="color: #172b4d;">${escapeHtml(assignee)}</span> • Added: <span style="color: #ff991f;">${createdDate}</span>
                        </div>
                    </td>
                </tr>
            </table>
        `;
    }

    formattedAdditions += string `
            </td>
        </tr>
    `;

    return formattedAdditions;
}


