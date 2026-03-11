import ballerina/log;
import ballerina/task;
import ballerina/time;

const int MAX_CRON_SEARCH_MINUTES = 366 * 24 * 60;
final int[] MONTH_OFFSETS = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];

class TrelloSummaryJob {

    *task:Job;

    public function execute() {
        error? result = sendTrelloSummary();
        if result is error {
            log:printError("Failed to send Trello summary", 'error = result);
        } else {
            log:printInfo("Trello summary sent successfully");
        }

        task:JobId|error nextJob = scheduleNextTrelloSummary();
        if nextJob is error {
            log:printError("Failed to schedule the next Trello summary", 'error = nextJob);
        }
    }
}

function scheduleNextTrelloSummary() returns task:JobId|error {
    time:Civil nextRun = check getNextCronOccurrence(scheduleConfig.cron, time:utcNow());
    task:JobId jobId = check task:scheduleOneTimeJob(new TrelloSummaryJob(), nextRun);
    log:printInfo(string `Next Trello summary scheduled for ${formatScheduledTime(nextRun)} with ID: ${jobId.id.toString()}`);
    return jobId;
}

function sendTrelloSummary() returns error? {
    log:printInfo("Starting Trello summary generation...");

    //Fetch cards
    CardSummary[] cards = check fetchTrelloCards();
    log:printInfo(string `Fetched ${cards.length().toString()} cards`);

    if cards.length() == 0 {
        log:printInfo("No cards found matching the criteria. Skipping email.");
        return;
    }

    int overdueCount = countOverdueCards(cards);

    GroupedSummary[] groupedSummaries = groupCards(cards);
    log:printInfo(string `Grouped cards into ${groupedSummaries.length().toString()} groups`);

    string emailContent = generateEmailContent(groupedSummaries, cards.length(), overdueCount);

    check sendEmailSummary(emailContent);
    log:printInfo("Email sent successfully");
}

function getNextCronOccurrence(string cron, time:Utc fromTime) returns time:Civil|error {
    string[] parts = re ` `.split(cron.trim());

    if parts.length() != 5 {
        return error("Invalid cron expression format");
    }

    time:Utc candidateUtc = check getNextMinuteBoundary(fromTime);
    int attempts = 0;
    while attempts < MAX_CRON_SEARCH_MINUTES {
        time:Civil candidate = time:utcToCivil(candidateUtc);
        if check matchesCron(parts, candidate) {
            return candidate;
        }

        candidateUtc = time:utcAddSeconds(candidateUtc, 60);
        attempts += 1;
    }

    return error(string `Could not find a matching execution time for cron expression: ${cron}`);
}

function getNextMinuteBoundary(time:Utc fromTime) returns time:Utc|error {
    time:Civil civil = time:utcToCivil(fromTime);
    time:Civil rounded = {
        year: civil.year,
        month: civil.month,
        day: civil.day,
        hour: civil.hour,
        minute: civil.minute,
        second: 0,
        utcOffset: civil.utcOffset,
        timeAbbrev: civil.timeAbbrev
    };
    time:Utc roundedUtc = check time:utcFromCivil(rounded);
    return time:utcAddSeconds(roundedUtc, 60);
}

function matchesCron(string[] parts, time:Civil candidate) returns boolean|error {
    if !(check matchesCronField(parts[0], candidate.minute, 0, 59)) {
        return false;
    }
    if !(check matchesCronField(parts[1], candidate.hour, 0, 23)) {
        return false;
    }
    if !(check matchesCronField(parts[3], candidate.month, 1, 12)) {
        return false;
    }

    return matchesDayFields(parts[2], parts[4], candidate);
}

function matchesDayFields(string dayOfMonthField, string dayOfWeekField, time:Civil candidate) returns boolean|error {
    boolean dayOfMonthMatches = check matchesCronField(dayOfMonthField, candidate.day, 1, 31);
    int dayOfWeek = getDayOfWeek(candidate);
    boolean dayOfWeekMatches = check matchesCronField(dayOfWeekField, dayOfWeek, 0, 6, allowSevenAsSunday = true);

    boolean isDayOfMonthWildcard = dayOfMonthField.trim() == "*";
    boolean isDayOfWeekWildcard = dayOfWeekField.trim() == "*";

    if isDayOfMonthWildcard && isDayOfWeekWildcard {
        return true;
    }
    if isDayOfMonthWildcard {
        return dayOfWeekMatches;
    }
    if isDayOfWeekWildcard {
        return dayOfMonthMatches;
    }

    return dayOfMonthMatches || dayOfWeekMatches;
}

function matchesCronField(string expression, int value, int min, int max, boolean allowSevenAsSunday = false) returns boolean|error {
    foreach string rawSegment in re `,`.split(expression) {
        string segment = rawSegment.trim();
        if segment.length() == 0 {
            return error(string `Invalid cron field segment in: ${expression}`);
        }

        if check matchesCronSegment(segment, value, min, max, allowSevenAsSunday) {
            return true;
        }
    }

    return false;
}

function matchesCronSegment(string segment, int value, int min, int max, boolean allowSevenAsSunday) returns boolean|error {
    string base = segment;
    int step = 1;

    if segment.indexOf("/") is int {
        string[] stepParts = re `/`.split(segment);
        if stepParts.length() != 2 {
            return error(string `Invalid cron step segment: ${segment}`);
        }

        base = stepParts[0].trim();
        step = check parseCronNumber(stepParts[1].trim(), 1, max, string `step in ${segment}`);
        if step <= 0 {
            return error(string `Cron step must be greater than zero: ${segment}`);
        }
    }

    if base == "*" {
        return (value - min) % step == 0;
    }

    if base.indexOf("-") is int {
        string[] rangeParts = re `-`.split(base);
        if rangeParts.length() != 2 {
            return error(string `Invalid cron range segment: ${segment}`);
        }

        int rangeStart = check parseCronFieldValue(rangeParts[0].trim(), min, max, allowSevenAsSunday, segment);
        int rangeEnd = check parseCronFieldValue(rangeParts[1].trim(), min, max, allowSevenAsSunday, segment);
        if rangeEnd < rangeStart {
            return error(string `Invalid descending cron range: ${segment}`);
        }

        return value >= rangeStart && value <= rangeEnd && (value - rangeStart) % step == 0;
    }

    int exactValue = check parseCronFieldValue(base, min, max, allowSevenAsSunday, segment);
    if step != 1 {
        return value == exactValue;
    }
    return value == exactValue;
}

function parseCronFieldValue(string token, int min, int max, boolean allowSevenAsSunday, string segment) returns int|error {
    int value = check parseCronNumber(token, min, max, string `value in ${segment}`);
    if allowSevenAsSunday && value == 7 {
        return 0;
    }
    return value;
}

function parseCronNumber(string token, int min, int max, string fieldName) returns int|error {
    int|error parsed = int:fromString(token);
    if parsed is error {
        return error(string `Invalid cron ${fieldName}: ${token}`);
    }
    if parsed < min || parsed > max {
        return error(string `Cron ${fieldName} must be between ${min.toString()} and ${max.toString()}: ${token}`);
    }
    return parsed;
}

function getDayOfWeek(time:Civil candidate) returns int {
    int year = candidate.year;
    int month = candidate.month;
    if month < 3 {
        year -= 1;
    }

    return (year + year / 4 - year / 100 + year / 400 + MONTH_OFFSETS[candidate.month - 1] + candidate.day) % 7;
}

function formatScheduledTime(time:Civil scheduledTime) returns string {
    return string `${scheduledTime.year}-${scheduledTime.month.toString().padZero(2)}-${scheduledTime.day.toString().padZero(2)} ${scheduledTime.hour.toString().padZero(2)}:${scheduledTime.minute.toString().padZero(2)} UTC`;
}
