import ballerina/log;
import ballerinax/sap.businessone.administration;

public function main() returns error? {
    do {
        administration:CompanyInfo administrationCompanyinfo = check administrationClient->companyServiceGetCompanyInfo();
        log:printInfo(administrationCompanyinfo.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

