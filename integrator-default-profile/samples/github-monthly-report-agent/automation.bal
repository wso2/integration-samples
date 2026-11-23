import ballerina/log;

public function main() returns error? {
    do {
        string summary = check reportAgent.run("Generate and send this month's report.");
        log:printInfo("Monthly report sent", summary = summary);
    } on fail error e {
        log:printError("Error occurred while generating the monthly report", 'error = e);
        return e;
    }
}
