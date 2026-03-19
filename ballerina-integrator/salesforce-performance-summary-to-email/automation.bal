import ballerina/log;

public function main() returns error? {
    do {
        if salesforceReportId == "" {
            return error("Salesforce Report ID is required. Please configure 'salesforceReportId' in Config.toml");
        }
        log:printInfo(string `Report ID: ${salesforceReportId}`);
        ReportSummary reportSummary = check generateReportSummary(salesforceReportId);
        log:printInfo(string `Period: ${reportSummary.periodStart} to ${reportSummary.periodEnd}`);

        check sendPerformanceEmailNew(reportSummary);
    } on fail error e {
        log:printError("Error occurred during automation", 'error = e);
        return e;
    }
}
