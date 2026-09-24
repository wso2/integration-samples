import ballerina/log;
import ballerinax/sap.successfactors.ecemployeeprofile;

public function main() returns error? {
    do {
        ecemployeeprofile:Wrapper ecemployeeprofileWrapper = check ecemployeeprofileClient->listBackgroundCommunities();
        log:printInfo(ecemployeeprofileWrapper.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
