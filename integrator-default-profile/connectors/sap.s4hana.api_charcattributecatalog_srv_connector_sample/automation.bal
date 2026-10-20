import ballerina/log;
import ballerinax/sap.s4hana.api_charcattributecatalog_srv;

public function main() returns error? {
    do {
        api_charcattributecatalog_srv:CollectionOfA_CharcAttribSeldCodeSetWrapper result = check apiCharcattributecatalogSrvClient->listA_CharcAttribSeldCodeSets(\$top = 10);
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
