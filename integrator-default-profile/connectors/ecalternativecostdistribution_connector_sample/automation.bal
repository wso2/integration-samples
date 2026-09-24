import ballerina/log;
import ballerinax/sap.successfactors.ecalternativecostdistribution;

public function main() returns error? {
    do {
        ecalternativecostdistribution:Wrapper ecalternativecostdistributionWrapper = check ecalternativecostdistributionClient->listEmpCostDistributions();
        log:printInfo(ecalternativecostdistributionWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
