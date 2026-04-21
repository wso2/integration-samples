import ballerina/log;
import ballerinax/guidewire.insnow;

public function main() returns error? {
    do {
        insnow:ListCountry insnowListcountry = check insnowClient->/addresses/countries.get();
        log:printInfo(insnowListcountry.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
    
}
