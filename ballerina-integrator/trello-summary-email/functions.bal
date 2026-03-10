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

// Fetch all cards from specified boards and lists
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

        // Get lists from board - workaround for ambiguous resource access
        json boardJson = board.toJson();
        json listsJson = check boardJson.lists;
        json[] listsArray = check listsJson.ensureType();

        foreach json listJson in listsArray {
            string listId = check listJson.id;
            string listName = check listJson.name;

            // Filter by list IDs if specified
            if (trelloConfig.listIds.length() > 0 && trelloConfig.listIds.indexOf(listId) is ()) {
                continue;
            }

            // Fetch as raw JSON to tolerate Trello payload shape changes.
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

// Process a single card from JSON and apply filters
function processCardFromJson(json cardJson, string listName, string boardName) returns CardSummary?|error {
    string cardId = check cardJson.id;
    string cardName = check cardJson.name;
    string cardUrl = check cardJson.url;
    string? cardDesc = check cardJson.desc;
    string description = cardDesc is string ? cardDesc : "";

    // Calculate card age
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

    // Get attachment count and checklist progress from badges
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

    // Extract labels
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

    // Apply label filter
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

    // Extract member information
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

    // Apply member filter
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

    // Parse due date
    time:Civil? dueDate = ();
    boolean isOverdue = false;
    string? dueDateStr = check cardJson.due;

    if dueDateStr is string {
        time:Utc dueDateUtc = check time:utcFromString(dueDateStr);
        dueDate = time:utcToCivil(dueDateUtc);

        // Check if overdue
        time:Utc currentTime = time:utcNow();
        if dueDateUtc < currentTime {
            isOverdue = true;
        }

        // Apply due date filter
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

// Group cards based on configuration
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

// Generate HTML email content
function generateEmailContent(GroupedSummary[] groupedSummaries, int totalCards, int overdueCount) returns string {
    string html = string `<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #0079bf; border-bottom: 3px solid #0079bf; padding-bottom: 10px; }
        h2 { color: #172b4d; margin-top: 30px; background-color: #f4f5f7; padding: 10px; border-radius: 3px; }
        .card { background-color: #fff; border: 1px solid #dfe1e6; border-radius: 3px; padding: 15px; margin: 10px 0; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
        .card-title { font-size: 16px; font-weight: bold; color: #172b4d; margin-bottom: 8px; }
        .card-title a { color: #0079bf; text-decoration: none; }
        .card-title a:hover { text-decoration: underline; }
        .card-meta { font-size: 13px; color: #5e6c84; margin: 5px 0; }
        .overdue { color: #eb5a46; font-weight: bold; }
        .label { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 12px; margin-right: 5px; background-color: #61bd4f; color: white; }
        .member { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 12px; margin-right: 5px; background-color: #0079bf; color: white; }
        .summary { background-color: #f4f5f7; padding: 15px; border-radius: 3px; margin-bottom: 20px; }
        .description { font-size: 13px; color: #5e6c84; margin-top: 8px; white-space: pre-wrap; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Trello Cards Summary</h1>
        <div class="summary">
            <strong>Total Cards:</strong> ${totalCards.toString()}<br/>`;

    if summaryConfig.highlightOverdueCards && overdueCount > 0 {
        html += string `            <strong class="overdue">Overdue Cards:</strong> ${overdueCount.toString()}<br/>`;
    }

    html += string `            <strong>Grouped By:</strong> ${summaryConfig.grouping.toString()}<br/>
            <strong>Generated:</strong> ${time:utcToString(time:utcNow())}
        </div>`;

    foreach GroupedSummary group in groupedSummaries {
        html += string `
        <h2>${group.groupName} (${group.cards.length().toString()} cards)</h2>`;

        foreach CardSummary card in group.cards {
            string overdueIndicator = summaryConfig.highlightOverdueCards && card.isOverdue ? " <span class=\"overdue\">OVERDUE</span>" : "";

            html += string `
        <div class="card">
            <div class="card-title"><a href="${card.url}" target="_blank">${card.name}</a>${overdueIndicator}</div>
            <div class="card-meta"><strong>Board:</strong> ${card.boardName} | <strong>List:</strong> ${card.listName}</div>`;

            if card.dueDate is time:Civil {
                time:Civil dueDate = <time:Civil>card.dueDate;
                string dueDateStr = string `${dueDate.year}-${dueDate.month.toString().padZero(2)}-${dueDate.day.toString().padZero(2)}`;
                html += string `
            <div class="card-meta"><strong>Due Date:</strong> ${dueDateStr}</div>`;
            }

            if card.labels.length() > 0 {
                html += string `
            <div class="card-meta"><strong>Labels:</strong> `;
                foreach string label in card.labels {
                    html += string `<span class="label">${label}</span>`;
                }
                html += "</div>";
            }

            if card.members.length() > 0 {
                html += string `
            <div class="card-meta"><strong>Members:</strong> `;
                foreach string member in card.members {
                    html += string `<span class="member">${member}</span>`;
                }
                html += "</div>";
            }

            if card.description.trim().length() > 0 {
                string truncatedDesc = card.description.length() > 200 ? card.description.substring(0, 200) + "..." : card.description;
                html += string `
            <div class="description">${truncatedDesc}</div>`;
            }

            // Show card age
            if summaryConfig.showCardAge {
                html += string `
            <div class="card-meta"><strong>Card Age:</strong> ${card.cardAgeDays.toString()} days</div>`;
            }

            // Show attachment count
            if summaryConfig.showAttachmentCount && card.attachmentCount > 0 {
                html += string `
            <div class="card-meta"><strong>Attachments:</strong> ${card.attachmentCount.toString()}</div>`;
            }

            // Show checklist progress
            if summaryConfig.showChecklistProgress && card.checklistItemsTotal > 0 {
                string checklistPercentage = formatPercentageTwoDecimals(card.checklistCompletionPercentage);
                html += string `
            <div class="card-meta"><strong>Checklist:</strong> ${card.checklistItemsCompleted.toString()}/${card.checklistItemsTotal.toString()} (${checklistPercentage}%)</div>`;
            }

            html += string `
        </div>`;
        }
    }

    html += string `
    </div>
</body>
</html>`;

    return html;
}

function formatPercentageTwoDecimals(decimal value) returns string {
    decimal rounded = value.round(2);
    int wholePart = <int>rounded;
    int decimalPart = <int>((rounded - <decimal>wholePart) * 100);

    return string `${wholePart.toString()}.${decimalPart.toString().padZero(2)}`;
}

// Send email with summary using Mailchimp
function sendEmailSummary(string htmlContent) returns error? {
    string subject = string `${mailchimpConfig.subjectPrefix} - ${time:utcToString(time:utcNow())}`;

    // Create a campaign
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

    // Set campaign content
    _ = check mailchimpClient->putCampaignsIdContent(
        campaignId = campaignId,
        payload = {
            html: htmlContent
        }
    );

    // Send the campaign
    _ = check mailchimpClient->postCampaignsIdActionsSend(campaignId = campaignId);
}

// Calculate overdue count
function countOverdueCards(CardSummary[] cards) returns int {
    int count = 0;
    foreach CardSummary card in cards {
        if card.isOverdue {
            count += 1;
        }
    }
    return count;
}
