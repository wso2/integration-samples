import ballerina/log;
import ballerinax/sap.businessone.humanresources;

public function main() returns error? {
    do {
        humanresources:EmployeesInfoCollectionResponse humanresourcesEmployeesinfocollectionresponse = check humanresourcesClient->listEmployeesInfo();
        log:printInfo(humanresourcesEmployeesinfocollectionresponse.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

