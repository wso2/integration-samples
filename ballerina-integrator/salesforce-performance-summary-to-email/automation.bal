import ballerina/io;
import ballerina/log;

public function main() returns error? {
    do {
        [string, string] currentDates = check getCurrentPeriodDates();
        string currentStartDate = currentDates[0];
        string currentEndDate = currentDates[1];

        [string, string] previousDates = check getPreviousPeriodDates();
        string previousStartDate = previousDates[0];
        string previousEndDate = previousDates[1];

        if salesforceReportId == "" {
            return error("Salesforce Report ID is required. Please configure 'salesforceReportId' in Config.toml");
        }

        io:println(string `Report ID: ${salesforceReportId}`);
        io:println(string `Period: ${currentStartDate} to ${currentEndDate}`);

        ReportSummary reportSummary = check generateReportSummary(
                salesforceReportId,
                currentStartDate,
                currentEndDate,
                previousStartDate,
                previousEndDate
        );

        check sendPerformanceEmailNew(reportSummary);
    } on fail error e {
        log:printError("Error occurred during automation", 'error = e);
        return e;
    }
}
