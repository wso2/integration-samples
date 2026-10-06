import ballerina/log;
import ballerinax/googleapis.calendar;

public function main() returns error? {
    do {
        json jsonResult = check ecClient->listEmployeeTimes(\$filter = string `approvalStatus eq 'APPROVED' and startDate ge datetime'${today()}T00:00:00' and startDate le datetime'${tommorrow()}T23:59:59'`, \$orderby = ["startDate"], \$select = ["startDate", "userId", "endDate", "externalCode", "approvalStatus", "timeType"]);
        json[] leaves = check jsonResult.d.results.ensureType();
        foreach json leave in leaves {
            string userId = check leave.userId.ensureType();
            string externalCode = check leave.externalCode.ensureType();
            string startDate = check odataDateToIsoDate(check leave.startDate.ensureType());
            string endDate = check odataDateToIsoDate(check leave.endDate.ensureType());
            calendar:Event createdEvent = check calendarClient->createEvent("primary", {
                summary: string `[Out of office] ${userId.toString()}`,
                description: string `SuccessFactors leave ID: ${externalCode}`,
                'start: {date: startDate},
                end: {date: endDate}
            });
            log:printInfo("Created Google Calendar leave event", eventId = createdEvent.id, leaveId = externalCode);
        }
        log:printInfo("Leave synchronization complete");

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
