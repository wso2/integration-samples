import ballerina/log;
import ballerinax/alfresco;

public function main() returns error? {
    do {
        alfresco:NodeEntry alfrescoNodeentry = check alfrescoClient->createNode(string `${alfrescoParentNodeId}`, {name: "IntegrationTestDocument", nodeType: "cm:content"});
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
