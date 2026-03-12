import ballerina/log;
import ballerinax/mailchimp.'transactional as mailchimp;

const string FONT_SANS = "font-family:-apple-system,BlinkMacSystemFont,'Helvetica Neue',Helvetica,Arial,sans-serif;";
const string FONT_MONO = "font-family:ui-monospace,'SF Mono',Consolas,monospace;";

const string COLOR_TEXT_PRIMARY = "#111111";
const string COLOR_TEXT_SECONDARY = "#888888";
const string COLOR_TEXT_MUTED = "#aaaaaa";
const string COLOR_TEXT_FAINT = "#bbbbbb";

const string COLOR_WHITE = "#ffffff";
const string COLOR_BORDER = "#ebebeb";
const string COLOR_DIVIDER = "#f5f5f5";
const string COLOR_SEPARATOR = "#cccccc";

const string COLOR_STATUS_YELLOW = "#D97706";
const string COLOR_STATUS_GREEN = "#059669";
const string COLOR_STATUS_BLUE = "#2563EB";
const string COLOR_STATUS_RED = "#DC2626";
const string COLOR_STATUS_PURPLE = "#7C3AED";
const string COLOR_STATUS_DEFAULT = "#6B7280";

const string STYLE_IMG_RESET = "display:block;border:0;";
const string STYLE_TEXT_PRIMARY = "color:" + COLOR_TEXT_PRIMARY + ";";
const string STYLE_TEXT_SECONDARY = "color:" + COLOR_TEXT_SECONDARY + ";";
const string STYLE_TEXT_MUTED = "color:" + COLOR_TEXT_MUTED + ";";
const string STYLE_BORDER_BOX = "border:1px solid " + COLOR_BORDER + ";";

function sendIssueSummary(Issue[] issues) returns error? {
    int totalIssues = issues.length();
    int maxDisplayCount = maxIssuesToDisplay > 0 ? maxIssuesToDisplay : 5;
    int displayCount = totalIssues < maxDisplayCount ? totalIssues : maxDisplayCount;
    Issue[] displayIssues = issues.slice(0, displayCount);
    int remainingCount = totalIssues - displayCount;

    string htmlContent = generateEmailHtml(displayIssues, remainingCount);

    mailchimp:MessagesSendBody messageRequest = {
        key: mailchimpConfig.mandrillApiKey,
        message: {
            html: htmlContent,
            subject: string `Jira Issue Summary - ${totalIssues} Issue${totalIssues > 1 ? "s" : ""}`,
            "from_email": mailchimpConfig.fromEmail,
            "from_name": mailchimpConfig.fromName,
            to: mailchimpConfig.recipients.map(function(string email) returns mailchimp:MessagessendMessageTo {
                return {
                    email: email,
                    'type: "to"
                };
            })
        }
    };

    mailchimp:InlineResponse20028[] _ = check mailchimpClient->/messages/send.post(messageRequest);
    log:printInfo("Email sent successfully");
}

function generateEmailHtml(Issue[] issues, int remainingCount) returns string {
    string issueCards = "";
    int cardIndex = 0;

    foreach Issue issue in issues {
        string assigneeSection = "";
        if issue.assignee is IssueAssignee {
            IssueAssignee assignee = <IssueAssignee>issue.assignee;
            assigneeSection = string `
                <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td valign="middle" style="padding-right:6px;">
                            <img src="${assignee.avatarUrl}"
                                 alt="${assignee.displayName}"
                                 width="18" height="18"
                                 style="${STYLE_IMG_RESET}border-radius:50%;">
                        </td>
                        <td valign="middle" style="${FONT_SANS}font-size:12px;${STYLE_TEXT_SECONDARY}">
                            ${assignee.displayName}
                        </td>
                    </tr>
                </table>`;
        } else {
            assigneeSection = string `<span style="${FONT_MONO}font-size:11px;${STYLE_TEXT_MUTED}">Unassigned</span>`;
        }

        string prioritySection = "";
        if issue.priority is IssuePriority {
            IssuePriority priority = <IssuePriority>issue.priority;
            prioritySection = string `
                <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td valign="middle" style="padding-right:4px;">
                            <img src="${priority.iconUrl}"
                                 alt="${priority.name}"
                                 width="13" height="13" style="${STYLE_IMG_RESET}">
                        </td>
                        <td valign="middle" style="${FONT_MONO}font-size:11px;${STYLE_TEXT_SECONDARY}">
                            ${priority.name}
                        </td>
                    </tr>
                </table>`;
        } else {
            prioritySection = string `<span style="${FONT_MONO}font-size:11px;${STYLE_TEXT_MUTED}">—</span>`;
        }

        string statusBg = getStatusColor(issue.status.colorName);
        string topBorder = cardIndex == 0 ? "border-top:1px solid " + COLOR_BORDER + ";" : "";
        cardIndex += 1;

        issueCards = issueCards + string `
            <tr>
                <td style="padding:0;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%"
                           style="${topBorder}border-left:1px solid ${COLOR_BORDER};border-right:1px solid ${COLOR_BORDER};border-bottom:1px solid ${COLOR_BORDER};background-color:${COLOR_WHITE};">

                        <tr>
                            <td style="padding:14px 20px 10px;">
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                    <tr>
                                        <td valign="middle">
                                            <a href="${issue.issueUrl}"
                                               style="${FONT_MONO}font-size:12px;font-weight:600;${STYLE_TEXT_PRIMARY}text-decoration:none;letter-spacing:0.02em;border-bottom:1px solid ${COLOR_TEXT_PRIMARY};padding-bottom:1px;">
                                                ${issue.key}
                                            </a>
                                        </td>
                                        <td valign="middle" align="right">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td valign="middle" style="padding-right:12px;">
                                                        ${prioritySection}
                                                    </td>
                                                    <td valign="middle">
                                                        <span style="display:inline-block;background-color:${statusBg};padding:3px 10px;${FONT_MONO}font-size:11px;font-weight:600;color:${COLOR_WHITE};letter-spacing:0.06em;text-transform:uppercase;">
                                                            ${issue.status.name}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td style="padding:6px 20px 12px;">
                                <a href="${issue.issueUrl}"
                                   style="${FONT_SANS}font-size:14px;font-weight:500;${STYLE_TEXT_PRIMARY}text-decoration:none;line-height:1.5;">
                                    ${issue.summary}
                                </a>
                            </td>
                        </tr>

                        <tr>
                            <td style="padding:10px 20px 14px;border-top:1px solid ${COLOR_DIVIDER};">
                                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                                    <tr>
                                        <td valign="middle">
                                            <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td valign="middle" style="padding-right:12px;">
                                                        ${getProjectSection(issue)}
                                                    </td>
                                                    <td valign="middle">
                                                        ${assigneeSection}
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td valign="middle" align="right">
                                            ${getMetadataSection(issue)}
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                    </table>
                </td>
            </tr>`;
    }

    string remainingSection = remainingCount > 0
        ? string `
            <tr>
                <td style="padding:16px 0 0;text-align:center;">
                    <span style="${FONT_SANS}font-size:12px;${STYLE_TEXT_SECONDARY}">
                        ${remainingCount} more issue${remainingCount > 1 ? "s" : ""} not shown &nbsp;&middot;&nbsp;
                        <a href="${getJiraUrl()}" style="${STYLE_TEXT_PRIMARY}text-decoration:underline;font-weight:500;">View all in Jira</a>
                    </span>
                </td>
            </tr>`
        : "";

    int issueCount = issues.length();

    return string `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="x-apple-disable-message-reformatting">
    <title>Jira Issue Summary</title>
    <style type="text/css">
        table,td{border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;}
        img{border:0;line-height:100%;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic;}
        body{margin:0!important;padding:0!important;width:100%!important;-webkit-text-size-adjust:100%;background-color:${COLOR_WHITE};}
        @media screen and (max-width:620px){
            .email-container{width:100%!important;}
            .hide-mobile{display:none!important;}
        }
    </style>
</head>
<body style="margin:0;padding:0;background-color:${COLOR_WHITE};">
    <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">
        ${issueCount} Jira issue${issueCount > 1 ? "s" : ""} require your attention
    </div>

    <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0"
           width="640" style="margin:auto;" class="email-container">

        <tr>
            <td style="background-color:${COLOR_WHITE};padding:28px 32px;border-left:1px solid ${COLOR_BORDER};border-right:1px solid ${COLOR_BORDER};border-top:1px solid ${COLOR_BORDER};">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                    <tr>
                        <td>
                            <p style="margin:0 0 4px;${FONT_MONO}font-size:10px;font-weight:600;${STYLE_TEXT_MUTED}letter-spacing:0.12em;text-transform:uppercase;">Issue Summary</p>
                            <p style="margin:0;${FONT_SANS}font-size:22px;font-weight:600;${STYLE_TEXT_PRIMARY}line-height:1.2;">
                                ${issueCount} open issue${issueCount > 1 ? "s" : ""}
                            </p>
                        </td>
                        <td width="36" align="right" valign="top">
                            <img src="https://wac-cdn.atlassian.com/dam/jcr:fa01756d-6dcc-45d1-83ab-696fbfeb074f/Jira-icon-blue.svg"
                                 width="28" height="28" alt="Jira"
                                 style="${STYLE_IMG_RESET}margin-left:auto;">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td style="padding:0 32px;border-left:1px solid ${COLOR_BORDER};border-right:1px solid ${COLOR_BORDER};background-color:${COLOR_WHITE};">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                    ${issueCards}
                    ${remainingSection}
                </table>
            </td>
        </tr>

        <tr>
            <td style="background-color:${COLOR_WHITE};padding:20px 32px 24px;border-left:1px solid ${COLOR_BORDER};border-right:1px solid ${COLOR_BORDER};border-bottom:1px solid ${COLOR_BORDER};text-align:right;">
                <a href="${getJiraUrl() + "/browse"}"
                   style="${FONT_MONO}font-size:11px;font-weight:600;${STYLE_TEXT_PRIMARY}text-decoration:none;letter-spacing:0.06em;text-transform:uppercase;border-bottom:1px solid ${COLOR_TEXT_PRIMARY};padding-bottom:2px;">
                    View all in Jira →
                </a>
            </td>
        </tr>

        <tr>
            <td style="padding:20px 32px;text-align:center;">
                <p style="margin:0;${FONT_SANS}font-size:11px;color:${COLOR_TEXT_FAINT};line-height:1.6;">
                    You are receiving this email because you subscribed to our updates.
                </p>
            </td>
        </tr>

        <tr><td height="32" style="font-size:0;line-height:0;">&nbsp;</td></tr>
    </table>
</body>
</html>`;
}

function getStatusColor(string colorName) returns string {
    match colorName {
        "yellow" => {
            return COLOR_STATUS_YELLOW;
        }
        "green" => {
            return COLOR_STATUS_GREEN;
        }
        "blue" => {
            return COLOR_STATUS_BLUE;
        }
        "red" => {
            return COLOR_STATUS_RED;
        }
        "purple" => {
            return COLOR_STATUS_PURPLE;
        }
        _ => {
            return COLOR_STATUS_DEFAULT;
        }
    }
}

function getProjectSection(Issue issue) returns string {
    if issue.project is IssueProject {
        IssueProject project = <IssueProject>issue.project;
        if project.avatarUrl != "" {
            return string `
                <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                        <td valign="middle" style="padding-right:5px;">
                            <img src="${project.avatarUrl}"
                                 alt="${project.name}"
                                 width="18" height="18"
                                 style="${STYLE_IMG_RESET}border-radius:3px;">
                        </td>
                        <td valign="middle" style="${FONT_MONO}font-size:11px;${STYLE_TEXT_SECONDARY}">
                            ${project.name}
                        </td>
                    </tr>
                </table>`;
        } else {
            return string `<span style="${FONT_MONO}font-size:11px;${STYLE_TEXT_SECONDARY}">${project.name}</span>`;
        }
    }
    return "";
}

function getMetadataSection(Issue issue) returns string {
    string duePart = "";
    if issue.dueDate is string {
        string formatted = formatDate(<string>issue.dueDate);
        duePart = string `<span style="${FONT_MONO}font-size:10px;${STYLE_TEXT_SECONDARY}">Due: ${formatted}</span>`;
    }

    string updatedPart = "";
    if issue.updated is string {
        string formatted = formatDate(<string>issue.updated);
        updatedPart = string `<span style="${FONT_MONO}font-size:10px;${STYLE_TEXT_SECONDARY}">Updated: ${formatted}</span>`;
    }

    if duePart == "" && updatedPart == "" {
        return "";
    }

    string separator = string `<span style="color:${COLOR_SEPARATOR};padding:0 6px;">&middot;</span>`;

    if duePart != "" && updatedPart != "" {
        return duePart + separator + updatedPart;
    }
    return duePart != "" ? duePart : updatedPart;
}

function formatDate(string isoDate) returns string {
    if isoDate.length() < 10 {
        return isoDate;
    }
    string datePart = isoDate.substring(0, 10);
    return string `${datePart.substring(8, 10)}/${datePart.substring(5, 7)}/${datePart.substring(0, 4)}`;
}

function getJiraUrl() returns string {
    return string `https://${jiraConfig.domain}.atlassian.net`;
}

function getJiraApiUrl() returns string {
    return string `https://${jiraConfig.domain}.atlassian.net/rest`;
}
