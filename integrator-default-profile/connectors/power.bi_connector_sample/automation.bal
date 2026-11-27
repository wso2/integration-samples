import ballerina/log;
import ballerinax/power.bi;

public function main() returns error? {
    do {
        bi:Datasets datasets = check biClient->getDatasets();
        log:printInfo(datasets.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
