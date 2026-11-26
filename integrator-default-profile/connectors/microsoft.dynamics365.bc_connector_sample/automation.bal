import ballerina/log;
import ballerinax/microsoft.dynamics365.bc;

public function main() returns error? {
    do {
        bc:CompanyCollection companies = check bcClient->listCompanies();
        log:printInfo(companies.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
