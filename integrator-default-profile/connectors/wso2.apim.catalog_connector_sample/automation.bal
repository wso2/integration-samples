import ballerina/log;
import ballerinax/wso2.apim.catalog;

public function main() returns error? {
    do {
        catalog:ServiceInfoList catalogServiceinfolist = check catalogClient->/services/'import.post({file: {fileContent: [], fileName: "SampleService.yaml"}});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
