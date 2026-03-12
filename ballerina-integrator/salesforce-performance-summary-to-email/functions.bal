import ballerina/lang.regexp;
import ballerina/time as time;
import ballerina/io;
import ballerina/url;
import ballerinax/mailchimp.'transactional as mailchimp;

public function getCurrentPeriodDates() returns [string, string]|error {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);

    time:Civil startDate;
    time:Civil endDate;

    if timePeriod == "monthly" {
        int lastMonth = currentCivil.month - 1;
        int year = currentCivil.year;
        if lastMonth < 1 {
            lastMonth = 12;
            year = year - 1;
        }
        startDate = {
            year: year,
            month: lastMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = lastMonth + 1;
        int endYear = year;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else {
        time:Utc startUtc = time:utcAddSeconds(currentUtc, -2592000.0);
        startDate = time:utcToCivil(startUtc);
        endDate = currentCivil;
    }

    string startDateStr = check time:civilToString(startDate);
    string endDateStr = check time:civilToString(endDate);

    regexp:RegExp datePattern = re `^\d{4}-\d{2}-\d{2}`;
    regexp:Span? startMatch = datePattern.find(startDateStr);
    regexp:Span? endMatch = datePattern.find(endDateStr);

    string finalStartDate = startMatch is regexp:Span ? startDateStr.substring(startMatch.startIndex, startMatch.endIndex) : startDateStr;
    string finalEndDate = endMatch is regexp:Span ? endDateStr.substring(endMatch.startIndex, endMatch.endIndex) : endDateStr;

    return [finalStartDate, finalEndDate];
}

public function getPreviousPeriodDates() returns [string, string]|error {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentCivil = time:utcToCivil(currentUtc);

    time:Civil startDate;
    time:Civil endDate;

    if comparisonPeriod == "MoM" {
        int twoMonthsAgo = currentCivil.month - 2;
        int year = currentCivil.year;
        if twoMonthsAgo < 1 {
            twoMonthsAgo = twoMonthsAgo + 12;
            year = year - 1;
        }
        startDate = {
            year: year,
            month: twoMonthsAgo,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = twoMonthsAgo + 1;
        int endYear = year;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else if comparisonPeriod == "YoY" {
        int lastYear = currentCivil.year - 1;
        int lastMonth = currentCivil.month - 1;
        if lastMonth < 1 {
            lastMonth = 12;
            lastYear = lastYear - 1;
        }
        startDate = {
            year: lastYear,
            month: lastMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };

        int nextMonth = lastMonth + 1;
        int endYear = lastYear;
        if nextMonth > 12 {
            nextMonth = 1;
            endYear = endYear + 1;
        }
        time:Civil tempDate = {
            year: endYear,
            month: nextMonth,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            utcOffset: {hours: 0, minutes: 0}
        };
        time:Utc tempUtc = check time:utcFromCivil(tempDate);
        time:Utc endUtc = time:utcAddSeconds(tempUtc, -86400.0);
        endDate = time:utcToCivil(endUtc);
    } else {
        time:Utc startUtc = time:utcAddSeconds(currentUtc, -5184000.0);
        time:Utc endUtc = time:utcAddSeconds(currentUtc, -2592000.0);
        startDate = time:utcToCivil(startUtc);
        endDate = time:utcToCivil(endUtc);
    }

    string startDateStr = check time:civilToString(startDate);
    string endDateStr = check time:civilToString(endDate);

    regexp:RegExp datePattern = re `^\d{4}-\d{2}-\d{2}`;
    regexp:Span? startMatch = datePattern.find(startDateStr);
    regexp:Span? endMatch = datePattern.find(endDateStr);

    string finalStartDate = startMatch is regexp:Span ? startDateStr.substring(startMatch.startIndex, startMatch.endIndex) : startDateStr;
    string finalEndDate = endMatch is regexp:Span ? endDateStr.substring(endMatch.startIndex, endMatch.endIndex) : endDateStr;

    return [finalStartDate, finalEndDate];
}

public function calculatePercentageChange(decimal current, decimal previous) returns decimal {
    if previous == 0.0d {
        return current > 0.0d ? 100.0d : 0.0d;
    }
    return ((current - previous) / previous) * 100.0d;
}

public function roundToTwoDecimals(decimal value) returns decimal {
    decimal multiplied = value * 100.0;
    int rounded = <int>multiplied;
    return <decimal>rounded / 100.0;
}

public function formatCurrency(decimal amount) returns string {
    decimal rounded = roundToTwoDecimals(amount);
    return string `${rounded.toString()}`;
}

public function formatPercentage(decimal percentage) returns string {
    decimal rounded = roundToTwoDecimals(percentage);
    string sign = rounded >= 0.0d ? "+" : "";
    return string `${sign}${rounded.toString()}%`;
}

public function getMonthName(string dateStr) returns string {
    string[] months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ];

    string[] parts = regexp:split(re `-`, dateStr);
    if parts.length() >= 2 {
        int|error monthNum = int:fromString(parts[1]);
        if monthNum is int && monthNum >= 1 && monthNum <= 12 {
            return months[monthNum - 1];
        }
    }
    return "Unknown";
}

public function getYear(string dateStr) returns string {
    string[] parts = regexp:split(re `-`, dateStr);
    if parts.length() >= 1 {
        return parts[0];
    }
    return "Unknown";
}

function formatMetricValue(MetricInfo metric) returns string {
    string lowerLabel = metric.label.toLowerAscii();
    string lowerName = metric.name.toLowerAscii();

    if lowerLabel.includes("count") || lowerLabel.includes("number") ||
        lowerName.includes("rowcount") || lowerName.includes("count") {
        int intValue = <int>metric.value;
        return intValue.toString();
    }

    if lowerLabel.includes("revenue") || lowerLabel.includes("amount") ||
        lowerLabel.includes("value") || lowerLabel.includes("price") ||
        lowerName.includes("amount") || lowerLabel.includes("total price") {
        return string `$${formatCurrency(metric.value)}`;
    }

    if lowerLabel.includes("rate") || lowerLabel.includes("percent") {
        return string `${formatCurrency(metric.value)}%`;
    }

    if lowerLabel.includes("duration") || lowerLabel.includes("time") {
        decimal rounded = roundToTwoDecimals(metric.value);
        string unit = lowerLabel.includes("hour") ? "hrs" :
                lowerLabel.includes("day") ? "days" : "";
        return string `${rounded.toString()} ${unit}`.trim();
    }

    return formatCurrency(metric.value);
}

function calculateChange(decimal current, decimal previous) returns decimal {
    if previous == 0.0d {
        return current > 0.0d ? 100.0d : 0.0d;
    }
    return roundToTwoDecimals(((current - previous) / previous) * 100.0d);
}

function generateChartUrl(ReportSummary summary) returns string {
    string[] labels = [];
    decimal[] currentData = [];
    decimal[] previousData = [];

    foreach MetricInfo metric in summary.currentMetrics {
        string label = metric.label;
        if label.startsWith("Sum of ") {
            label = label.substring(7);
        } else if label.startsWith("Average ") {
            label = label.substring(8);
        }
        labels.push(label);
    }

    foreach MetricInfo metric in summary.currentMetrics {
        currentData.push(metric.value);
    }

    foreach MetricInfo metric in summary.previousMetrics {
        previousData.push(metric.value);
    }

    string chartConfig = string `{
        "type": "bar",
        "data": {
            "labels": ${labels.toJsonString()},
            "datasets": [
                {
                    "label": "Current Period",
                    "data": ${currentData.toJsonString()},
                    "backgroundColor": "rgba(46, 164, 79, 0.8)"
                },
                {
                    "label": "Previous Period",
                    "data": ${previousData.toJsonString()},
                    "backgroundColor": "rgba(209, 213, 218, 0.8)"
                }
            ]
        },
        "options": {
            "scales": {
                "yAxes": [{
                    "ticks": {
                        "beginAtZero": true
                    }
                }]
            }
        }
    }`;

    string|url:Error encodedResult = url:encode(chartConfig, "UTF-8");
    string encodedChart = encodedResult is string ? encodedResult : chartConfig;
    return string `https://quickchart.io/chart?c=${encodedChart}&width=540&height=300`;
}

function generateRepRows(RepPerformance[] repBreakdown) returns string {
    if repBreakdown.length() == 0 {
        return string `<tr>
                <td colspan="2" style="padding: 15px; text-align: center; color: #586069; border: 1px solid #e1e4e8;">No rep breakdown available</td>
            </tr>`;
    }

    string rows = "";
    foreach RepPerformance rep in repBreakdown {
        rows += string `<tr>
                <td style="padding: 10px; border: 1px solid #e1e4e8; color: #24292e;">${rep.repName}</td>
                <td style="padding: 10px; border: 1px solid #e1e4e8; text-align: right; color: #24292e; font-weight: 600;">$${formatCurrency(rep.revenue)}</td>
            </tr>`;
    }
    return rows;
}

public function getSalesforcePerformanceEmail(ReportSummary summary, string period) returns string {
    boolean hasMetrics = summary.currentMetrics.length() > 0;
    string metricsHtml = "";

    if !hasMetrics {
        metricsHtml = string `
                <td colspan="3" align="center" style="font-family: sans-serif; padding: 40px;">
                    <div style="font-size: 18px; color: #586069; margin-bottom: 10px;">
                        <strong>No Data Available</strong>
                    </div>
                    <div style="font-size: 14px; color: #6a737d;">
                        No metrics found for the selected period.
                    </div>
                </td>`;
    } else {
        int metricCount = summary.currentMetrics.length();
        string colWidth = metricCount == 2 ? "50%" :
                metricCount == 3 ? "33%" :
                    metricCount == 4 ? "25%" :
                    string `${100 / metricCount}%`;

        foreach int i in 0 ..< metricCount {
            MetricInfo metric = summary.currentMetrics[i];
            MetricInfo prevMetric = summary.previousMetrics[i];
            decimal change = calculateChange(metric.value, prevMetric.value);
            string changeColor = change >= 0.0d ? "#2ea44f" : "#cb2431";
            string changeSign = change >= 0.0d ? "+" : "";
            string borderStyle = i > 0 ? "border-left: 1px solid #eeeeee;" : "";

            string formattedValue = formatMetricValue(metric);

            metricsHtml += string `
                <td width="${colWidth}" align="center" valign="top" style="font-family: sans-serif; ${borderStyle}">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            <td align="center" style="font-size: 22px; font-weight: bold; color: #24292e;">${formattedValue}</td>
                        </tr>
                        <tr>
                            <td align="center" style="font-size: 11px; color: #586069; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">${metric.label}</td>
                        </tr>
                        <tr>
                            <td align="center" style="font-size: 12px; color: ${changeColor}; font-weight: 600; padding-top: 5px;">
                                ${changeSign}${formatCurrency(change)}%
                            </td>
                        </tr>
                    </table>
                </td>`;
        }
    }

    string chartSection = "";
    if hasMetrics {
        chartSection = string `
            <tr>
                <td style="background-color: #ffffff; padding: 30px; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8;">
                    <div style="font-size: 16px; font-weight: 600; color: #24292e; margin-bottom: 15px;">Performance Trend</div>
                    <img src="${generateChartUrl(summary)}" width="540" style="display: block; border-radius: 4px; border: 1px solid #f0f1f2;" alt="Performance Chart">
                </td>
            </tr>`;
    }

    return string `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <style type="text/css">
        table, td { border-collapse: collapse; }
        body {
            margin: 0;
            padding: 0;
            width: 100% !important;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            background-color: #f6f8fa;
        }
    </style>
</head>
<body style="background-color: #f6f8fa;">
    <center style="width: 100%; background-color: #f6f8fa; padding-bottom: 40px;">
        <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="margin: auto;">
            <tr><td height="40"></td></tr>
            <tr>
                <td style="background-color: #24292e; padding: 30px; border-radius: 6px 6px 0 0;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            <td style="font-family: sans-serif; color: #ffffff;">
                                <div style="font-size: 14px; color: #a3aab1; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px;">Performance Report</div>
                                <div style="font-size: 20px; font-weight: 600;">${summary.reportName}</div>
                                <div style="font-size: 14px; color: #d1d5da; margin-top: 8px; opacity: 0.8;">Period: ${period}</div>
                            </td>
                            <td width="50" align="right">
                                <img src="https://upload.wikimedia.org/wikipedia/commons/f/f9/Salesforce.com_logo.svg" width="50" alt="Salesforce">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="background-color: #ffffff; padding: 25px 0; border-bottom: 1px solid #e1e4e8; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            ${metricsHtml}
                        </tr>
                    </table>
                </td>
            </tr>
            ${chartSection}
            <tr>
                <td style="background-color: #ffffff; padding: 0 30px 30px 30px; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8; border-radius: 0 0 6px 6px; border-bottom: 1px solid #e1e4e8;">
                    <div style="font-size: 16px; font-weight: 600; color: #24292e; margin-bottom: 15px;">Team Breakdown</div>
                    <table width="100%" style="font-size: 14px; text-align: left;">
                        <thead style="background-color: #f6f8fa; color: #586069;">
                            <tr>
                                <th style="padding: 10px; border: 1px solid #e1e4e8;">Team Member</th>
                                <th style="padding: 10px; border: 1px solid #e1e4e8; text-align: right;">Revenue</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${generateRepRows(summary.repBreakdown)}
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 30px; text-align: center; font-family: sans-serif; font-size: 12px; color: #6a737d;">
                    <p style="margin: 5px 0;">This report was generated automatically from Salesforce Analytics.</p>
                    <p style="margin: 5px 0; opacity: 0.7;">Report ID: ${summary.reportId}</p>
                </td>
            </tr>
        </table>
    </center>
</body>
</html>`;
}

public function generateEmailSubject(string periodStart) returns string {
    string monthName = getMonthName(periodStart);
    string year = getYear(periodStart);

    string subject = emailConfig.subjectTemplate;
    regexp:RegExp monthPattern = re `\{\{month\}\}`;
    subject = monthPattern.replaceAll(subject, monthName);
    regexp:RegExp yearPattern = re `\{\{year\}\}`;
    subject = yearPattern.replaceAll(subject, year);

    return subject;
}

public function sendPerformanceEmailNew(ReportSummary summary) returns error? {
    string period = string `${summary.periodStart} to ${summary.periodEnd}`;
    string htmlContent = getSalesforcePerformanceEmail(summary, period);
    string subject = generateEmailSubject(summary.periodStart);

    mailchimp:MessagessendMessageTo[] recipients = [];
    foreach string email in emailConfig.recipientEmails {
        recipients.push({
            email: email,
            'type: "to"
        });
    }

    mailchimp:MessagessendMessage message = {
        html: htmlContent,
        subject: subject,
        fromEmail: emailConfig.fromEmail,
        fromName: emailConfig.fromName,
        to: recipients,
        trackOpens: true,
        trackClicks: true,
        autoHtml: false,
        inlineCss: true
    };

    mailchimp:MessagesSendBody sendRequest = {
        'key: mailchimpConfig.mandrilApiKey,
        message: message,
        async: false
    };

    mailchimp:InlineResponse20028[] response = check mailchimpClient->/messages/send.post(sendRequest);

    foreach mailchimp:InlineResponse20028 result in response {
        string emailAddr = result?.email ?: "unknown";
        string status = result?.status ?: "unknown";
        if status == "sent" {
            io:println(string `Email sent successfully to ${emailAddr}`);
        } else {
            io:println(string `Email to ${emailAddr} has status: ${status}`);
            if result?.rejectReason is string {
                io:println(string `Reason: ${result?.rejectReason ?: ""}`);
            }
        }
    }
}
