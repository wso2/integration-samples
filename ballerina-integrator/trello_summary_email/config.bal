configurable record {
    string key;
    string token;
    string[] boardIds;
    string[] listIds;
} trelloConfig = ?;

configurable record {
    string apiKey;
    string serverPrefix;
    string listId;
    string fromName;
    string fromAddress;
    string subjectPrefix = "Trello Cards Summary";
} mailchimpConfig = ?;

configurable record {
    string cron = "0 9 * * 1";
} scheduleConfig = {};

configurable record {
    string[] labels = [];
    string[] members = [];
    boolean includeDueDateFilter = false;
    int dueDateDaysAhead = 7;
} filterConfig = {};

configurable record {
    SummaryGrouping grouping = LIST;
    boolean highlightOverdueCards = true;
    boolean showCardAge = true;
    int staleCardDays = 30;
    boolean showAttachmentCount = true;
    boolean showChecklistProgress = true;
} summaryConfig = {};

