import ballerina/log;

public function main() returns error? {
    do {
        if salesforceConfig.reportId == "" {
            return error("Salesforce Report ID is required. Please configure 'salesforceReportId' in Config.toml");
        }
        log:printInfo(string `Report ID: ${salesforceConfig.reportId}`);
        ReportSummary reportSummary = check generateReportSummary(salesforceConfig.reportId);
        log:printInfo(string `Period: ${civilDateToYmdString(reportSummary.periodStart)} to ${civilDateToYmdString(reportSummary.periodEnd)}`);

        check sendPerformanceEmailNew(reportSummary);
    } on fail error e {
        log:printError("Error occurred during automation", 'error = e);
        return e;
    }
}
