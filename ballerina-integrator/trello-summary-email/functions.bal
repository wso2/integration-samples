import ballerina/time;
import ballerinax/mailchimp;
import ballerinax/trello;

function fetchListCardsAsJson(string listId) returns json[]|error {
    json cardsJson = check trelloHttpClient->/lists/[listId]/cards.get(
           'key = trelloConfig.key,
           token = trelloConfig.token,
        fields = "id,name,url,desc,dateLastActivity,due,idMembers,labels,badges"
    );

    return check cardsJson.ensureType();
}

function fetchTrelloCards() returns CardSummary[]|error {
    CardSummary[] allCards = [];

    foreach string boardId in trelloConfig.boardIds {
        trello:Board board = check trelloClient->/boards/[boardId].get(
            checklists = "none",
            cards = "none",
            customFields = false,
            cardPluginData = false,
            memberships = "none",
            labels = "none",
            tags = false,
            boardStars = "none",
            lists = "all",
            members = "none",
            organization = false,
            organizationPluginData = false,
            pluginData = false,
            myPrefs = false,
            fields = "name",
            actions = "none"
        );
        string boardName = board.name ?: "Unknown Board";

        json boardJson = board.toJson();
        json listsJson = check boardJson.lists;
        json[] listsArray = check listsJson.ensureType();

        foreach json listJson in listsArray {
            string listId = check listJson.id;
            string listName = check listJson.name;

            if (trelloConfig.listIds.length() > 0 && trelloConfig.listIds.indexOf(listId) is ()) {
                continue;
            }

            json[] cardsArray = check fetchListCardsAsJson(listId);

            foreach json cardJson in cardsArray {
                CardSummary? cardSummary = check processCardFromJson(cardJson, listName, boardName);
                if cardSummary is CardSummary {
                    allCards.push(cardSummary);
                }
            }
        }
    }

    return allCards;
}

function processCardFromJson(json cardJson, string listName, string boardName) returns CardSummary?|error {
    string cardId = check cardJson.id;
    string cardName = check cardJson.name;
    string cardUrl = check cardJson.url;
    string? cardDesc = check cardJson.desc;
    string description = cardDesc is string ? cardDesc : "";

    int cardAgeDays = 0;
    boolean isStale = false;
    string? dateLastActivity = check cardJson.dateLastActivity;
    if dateLastActivity is string {
        time:Utc lastActivityUtc = check time:utcFromString(dateLastActivity);
        time:Utc currentTime = time:utcNow();
        decimal secondsDiff = time:utcDiffSeconds(currentTime, lastActivityUtc);
        cardAgeDays = <int>(secondsDiff / 86400);
            isStale = cardAgeDays >= summaryConfig.staleCardDays;
    }

    int attachmentCount = 0;
    int checklistItemsTotal = 0;
    int checklistItemsCompleted = 0;
    decimal checklistCompletionPercentage = 0.0;

    json? badgesJson = check cardJson.badges;
    if badgesJson is json {
        int? attachments = check badgesJson.attachments;
        int? checkItems = check badgesJson.checkItems;
        int? checkItemsChecked = check badgesJson.checkItemsChecked;

        attachmentCount = attachments ?: 0;
        checklistItemsTotal = checkItems ?: 0;
        checklistItemsCompleted = checkItemsChecked ?: 0;

        if checklistItemsTotal > 0 {
            checklistCompletionPercentage = (<decimal>checklistItemsCompleted / <decimal>checklistItemsTotal) * 100.0;
        }
    }

    string[] labelNames = [];
    json? labelsJson = check cardJson.labels;
    if labelsJson is json[] {
        foreach json labelJson in labelsJson {
            string? labelName = check labelJson.name;
            if labelName is string && labelName.trim().length() > 0 {
                labelNames.push(labelName);
            }
        }
    }

    if filterConfig.labels.length() > 0 {
        boolean hasMatchingLabel = false;
        foreach string filterLabel in filterConfig.labels {
            if labelNames.indexOf(filterLabel) !is () {
                hasMatchingLabel = true;
                break;
            }
        }
        if !hasMatchingLabel {
            return ();
        }
    }

    string[] memberNames = [];
    json? membersJson = check cardJson.idMembers;
    if membersJson is json[] {
        foreach json memberIdJson in membersJson {
            string? memberIdStr = memberIdJson.toString();
            if memberIdStr is string {
                trello:InlineResponse2001|error memberInfo = trelloClient->/members/[memberIdStr].get();
                if memberInfo is trello:InlineResponse2001 {
                    string? fullName = memberInfo?.fullName;
                    if fullName is string {
                        memberNames.push(fullName);
                    }
                }
            }
        }
    }

    if filterConfig.members.length() > 0 {
        boolean hasMatchingMember = false;
        foreach string filterMember in filterConfig.members {
            if memberNames.indexOf(filterMember) !is () {
                hasMatchingMember = true;
                break;
            }
        }
        if !hasMatchingMember {
            return ();
        }
    }

    time:Civil? dueDate = ();
    boolean isOverdue = false;
    string? dueDateStr = check cardJson.due;

    if dueDateStr is string {
        time:Utc dueDateUtc = check time:utcFromString(dueDateStr);
        dueDate = time:utcToCivil(dueDateUtc);

        time:Utc currentTime = time:utcNow();
        if dueDateUtc < currentTime {
            isOverdue = true;
        }

        if filterConfig.includeDueDateFilter {
            time:Utc futureTime = time:utcAddSeconds(currentTime, filterConfig.dueDateDaysAhead * 24 * 60 * 60);
            if dueDateUtc > futureTime {
                return ();
            }
        }
    }

    return {
        id: cardId,
        name: cardName,
        listName: listName,
        boardName: boardName,
        url: cardUrl,
        labels: labelNames,
        members: memberNames,
        dueDate: dueDate,
        isOverdue: isOverdue,
        description: description,
        cardAgeDays: cardAgeDays,
        isStale: isStale,
        attachmentCount: attachmentCount,
        checklistItemsTotal: checklistItemsTotal,
        checklistItemsCompleted: checklistItemsCompleted,
        checklistCompletionPercentage: checklistCompletionPercentage
    };
}

function groupCards(CardSummary[] cards) returns GroupedSummary[] {
    map<CardSummary[]> groupMap = {};

    foreach CardSummary card in cards {
        string[] groupKeys = [];

        match summaryConfig.grouping {
            LIST => {
                groupKeys.push(card.listName);
            }
            MEMBER => {
                if card.members.length() > 0 {
                    groupKeys = card.members;
                } else {
                    groupKeys.push("Unassigned");
                }
            }
            LABEL => {
                if card.labels.length() > 0 {
                    groupKeys = card.labels;
                } else {
                    groupKeys.push("No Labels");
                }
            }
        }

        foreach string groupKey in groupKeys {
            if !groupMap.hasKey(groupKey) {
                groupMap[groupKey] = [];
            }
            CardSummary[] existingCards = groupMap.get(groupKey);
            existingCards.push(card);
            groupMap[groupKey] = existingCards;
        }
    }

    GroupedSummary[] groupedSummaries = [];
    foreach string groupName in groupMap.keys() {
        CardSummary[] groupCardsList = groupMap.get(groupName);
        groupedSummaries.push({
            groupName: groupName,
            cards: groupCardsList
        });
    }

    return groupedSummaries;
}

function getFormattedTimestamp(time:Utc utcTime) returns string {
    time:Civil civil = time:utcToCivil(utcTime);
    return string `${civil.year}-${civil.month.toString().padZero(2)}-${civil.day.toString().padZero(2)} ${civil.hour.toString().padZero(2)}:${civil.minute.toString().padZero(2)} UTC`;
}

function getHtmlFormattedGroup(GroupedSummary group) returns string {
    string cardsHtml = "";
    foreach CardSummary card in group.cards {
        string leftBorder = card.isOverdue
            ? " style=\"border-left: 3px solid #de350b; padding: 16px 30px; border-bottom: 1px solid #e1e4e8;\""
            : (card.isStale
                ? " style=\"border-left: 3px solid #ff8b00; padding: 16px 30px; border-bottom: 1px solid #e1e4e8;\""
                : " style=\"padding: 16px 30px; border-bottom: 1px solid #e1e4e8;\"");

        string dueDateHtml = "";
        time:Civil? dueDate = card.dueDate;
        if dueDate is time:Civil {
            string dueDateStr = string `${dueDate.year}-${dueDate.month.toString().padZero(2)}-${dueDate.day.toString().padZero(2)}`;
            string dueDateColor = card.isOverdue ? "#de350b" : "#586069";
            dueDateHtml = string `<span style="color: ${dueDateColor};">Due: ${dueDateStr}</span>&nbsp;&nbsp;`;
        }

        string labelsHtml = "";
        foreach string label in card.labels {
            labelsHtml += string `<span style="display: inline-block; padding: 2px 6px; border-radius: 3px; font-size: 11px; background-color: #61bd4f; color: white; margin-right: 4px;">${label}</span>`;
        }

        string membersHtml = "";
        foreach string member in card.members {
            membersHtml += member + " ";
        }

        string cardAgeHtml = summaryConfig.showCardAge
            ? string `<span style="color: #586069;">Age: ${card.cardAgeDays.toString()} days</span>&nbsp;&nbsp;` : "";

        string attachmentsHtml = summaryConfig.showAttachmentCount && card.attachmentCount > 0
            ? string `<span style="color: #586069;">Attachments: ${card.attachmentCount.toString()}</span>&nbsp;&nbsp;` : "";

        string checklistHtml = "";
        if summaryConfig.showChecklistProgress && card.checklistItemsTotal > 0 {
            string pct = formatPercentageTwoDecimals(card.checklistCompletionPercentage);
            checklistHtml = string `<span style="color: #586069;">Checklist: ${card.checklistItemsCompleted.toString()}/${card.checklistItemsTotal.toString()} (${pct}%)</span>`;
        }

        string descHtml = "";
        if card.description.trim().length() > 0 {
            string truncatedDesc = card.description.length() > 200
                ? card.description.substring(0, 200) + "..." : card.description;
            descHtml = string `<div style="font-size: 13px; color: #586069; margin-top: 8px; white-space: pre-wrap;">${truncatedDesc}</div>`;
        }

        string overdueTag = summaryConfig.highlightOverdueCards && card.isOverdue
            ? "<span style=\"background-color: #de350b; color: white; font-size: 11px; padding: 1px 6px; border-radius: 3px; margin-left: 6px;\">OVERDUE</span>"
            : "";

        string metaHtml = dueDateHtml + cardAgeHtml + attachmentsHtml + checklistHtml;
        string labelsRow = labelsHtml.length() > 0 ? string `<div style="margin-top: 6px;">${labelsHtml}</div>` : "";
        string membersRow = membersHtml.trim().length() > 0
            ? string `<div style="font-size: 12px; color: #586069; margin-top: 6px;">Members: ${membersHtml.trim()}</div>` : "";

        cardsHtml += string `
                            <tr>
                                <td${leftBorder}>
                                    <a href="${card.url}" target="_blank" style="font-family: sans-serif; font-size: 14px; font-weight: 600; color: #0052cc; text-decoration: none;">${card.name}</a>${overdueTag}
                                    <div style="font-size: 12px; color: #586069; margin-top: 6px;">${metaHtml}</div>
                                    ${labelsRow}
                                    ${membersRow}
                                    ${descHtml}
                                </td>
                            </tr>`;
    }

    return string `
                <tr>
                    <td style="background-color: #f6f8fa; padding: 10px 30px; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8; border-bottom: 1px solid #e1e4e8;">
                        <span style="font-family: sans-serif; font-size: 14px; font-weight: 600; color: #24292e;">${group.groupName}</span>
                        <span style="font-family: sans-serif; font-size: 13px; font-weight: 400; color: #586069;"> (${group.cards.length().toString()} cards)</span>
                    </td>
                </tr>
                <tr>
                    <td style="background-color: #ffffff; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8;">
                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                            ${cardsHtml}
                        </table>
                    </td>
                </tr>`;
}

function formatPercentageTwoDecimals(decimal value) returns string {
    decimal rounded = value.round(2);
    int wholePart = <int>rounded;
    int decimalPart = <int>((rounded - <decimal>wholePart) * 100);

    return string `${wholePart.toString()}.${decimalPart.toString().padZero(2)}`;
}

function generateEmailContent(GroupedSummary[] groupedSummaries, int totalCards, int overdueCount) returns string {
    int staleCount = 0;
    foreach GroupedSummary group in groupedSummaries {
        foreach CardSummary card in group.cards {
            if card.isStale {
                staleCount += 1;
            }
        }
    }

    string groupedByStr = summaryConfig.grouping.toString();
    string generatedAt = getFormattedTimestamp(time:utcNow());

    string groupsHtml = "";
    foreach GroupedSummary group in groupedSummaries {
        groupsHtml += getHtmlFormattedGroup(group);
    }

    string overdueCountDisplay = summaryConfig.highlightOverdueCards ? overdueCount.toString() : "-";

    return string `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="x-apple-disable-message-reformatting">
    <title>Trello Cards Summary</title>
    <style type="text/css">
        table, td { border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
        body { height: 100% !important; margin: 0 !important; padding: 0 !important; width: 100% !important; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; -webkit-text-size-adjust: 100%; }
        @media screen and (max-width: 600px) {
            .email-container { width: 100% !important; margin: auto !important; }
        }
    </style>
</head>
<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #f6f8fa;">
    <center style="width: 100%; background-color: #f6f8fa;">

        <div style="display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;">
            Trello Cards Summary: ${totalCards.toString()} total, ${overdueCount.toString()} overdue, grouped by ${groupedByStr}
        </div>

        <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" style="margin: auto;" class="email-container">

            <tr><td height="40" style="font-size: 0; line-height: 0;">&nbsp;</td></tr>

            <tr>
                <td style="background-color: #0052cc; padding: 30px; border-radius: 6px 6px 0 0; text-align: left;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            <td style="font-family: sans-serif; font-size: 20px; font-weight: 600; color: #ffffff; line-height: 24px;">
                                Trello Cards Summary
                                <div style="font-size: 14px; color: #b3d0ff; font-weight: 400; margin-top: 5px;">Grouped by ${groupedByStr} &bull; ${generatedAt}</div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr>
                <td style="background-color: #ffffff; padding: 20px 0; border-bottom: 1px solid #e1e4e8; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            <td width="33%" align="center" valign="top" style="font-family: sans-serif;">
                                <div style="font-size: 24px; font-weight: bold; color: #24292e;">${totalCards.toString()}</div>
                                <div style="font-size: 11px; color: #586069; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Total Cards</div>
                            </td>
                            <td width="33%" align="center" valign="top" style="font-family: sans-serif; border-left: 1px solid #eeeeee; border-right: 1px solid #eeeeee;">
                                <div style="font-size: 24px; font-weight: bold; color: #de350b;">${overdueCountDisplay}</div>
                                <div style="font-size: 11px; color: #586069; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Overdue</div>
                            </td>
                            <td width="33%" align="center" valign="top" style="font-family: sans-serif;">
                                <div style="font-size: 24px; font-weight: bold; color: #ff8b00;">${staleCount.toString()}</div>
                                <div style="font-size: 11px; color: #586069; text-transform: uppercase; letter-spacing: 0.5px; padding-top: 5px;">Stale</div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            ${groupsHtml}

            <tr>
                <td style="padding: 30px; text-align: center; font-family: sans-serif; font-size: 12px; color: #6a737d; line-height: 20px; border-left: 1px solid #e1e4e8; border-right: 1px solid #e1e4e8; border-bottom: 1px solid #e1e4e8; border-radius: 0 0 6px 6px;">
                    <p style="margin: 0 0 10px 0;">You are receiving this Trello summary because it was scheduled via the Trello Summary Email integration.</p>
                    <p style="margin: 0;">
                        <a href="*|UNSUB|*" style="color: #6a737d; text-decoration: underline;">Unsubscribe</a>
                        &nbsp;&bull;&nbsp;
                        <a href="*|UPDATE_PROFILE|*" style="color: #6a737d; text-decoration: underline;">Update preferences</a>
                    </p>
                </td>
            </tr>

            <tr><td height="40" style="font-size: 0; line-height: 0;">&nbsp;</td></tr>

        </table>

    </center>
</body>
</html>`;
}

function sendEmailSummary(string htmlContent) returns error? {
    string subject = mailchimpConfig.subjectPrefix;
    if mailchimpConfig.includeDateInSubject {
        time:Civil currentDate = time:utcToCivil(time:utcNow());
        string dateStr = string `${currentDate.year}-${currentDate.month.toString().padZero(2)}-${currentDate.day.toString().padZero(2)}`;
        subject = string `${mailchimpConfig.subjectPrefix} - ${dateStr}`;
    }

    mailchimp:Campaign1 campaign = check mailchimpClient->postCampaigns({
        'type: "regular",
        recipients: {
                list_id: mailchimpConfig.listId
        },
        settings: {
            subject_line: subject,
            from_name: mailchimpConfig.fromName,
            reply_to: mailchimpConfig.fromAddress,
            title: subject
        }
    });

    string? campaignId = campaign?.id;
    if campaignId is () {
        return error("Failed to create campaign: Campaign ID is null");
    }

    _ = check mailchimpClient->putCampaignsIdContent(
        campaignId = campaignId,
        payload = {
            html: htmlContent
        }
    );

    _ = check mailchimpClient->postCampaignsIdActionsSend(campaignId = campaignId);
}

function countOverdueCards(CardSummary[] cards) returns int {
    int count = 0;
    foreach CardSummary card in cards {
        if card.isOverdue {
            count += 1;
        }
    }
    return count;
}
