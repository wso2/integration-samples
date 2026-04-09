import ballerina/log;
import ballerinax/peoplehr;

public function main() returns error? {
    do {
        peoplehr:EmployeeResponse peoplehrEmployeeresponse = check peoplehrClient->getEmployeeById({EmployeeId: "EMP001"});
        log:printInfo(peoplehrEmployeeresponse.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
