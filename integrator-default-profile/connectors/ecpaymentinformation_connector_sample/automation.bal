import ballerina/log;
import ballerinax/sap.successfactors.ecpaymentinformation;

public function main() returns error? {
    do {
        ecpaymentinformation:Wrapper ecpaymentinformationWrapper = check ecpaymentinformationClient->listPaymentInformationDetailV3KENs();
        log:printInfo(ecpaymentinformationWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
