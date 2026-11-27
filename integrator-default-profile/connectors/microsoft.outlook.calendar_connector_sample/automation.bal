import ballerina/log;
import ballerinax/microsoft.outlook.calendar;

public function main() returns error? {
    do {
        calendar:Calendar defaultCalendar = check calendarClient->getDefaultCalendar();
        log:printInfo(defaultCalendar.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
