import ballerina/log;

public function main() returns error? {
    do {
        check azFilesClient->uploadFromFile("./data/q1-report.pdf", "/reports/q1-report.pdf");
        boolean uploaded = check azFilesClient->hasFile("/reports/q1-report.pdf");
        log:printInfo(string `${uploaded}`);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
