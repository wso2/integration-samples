import ballerina/ai;
import ballerina/file;
import ballerina/log;

public function main() returns error? {
    check ingestProductDocs();
    log:printInfo("Inbound Sales Agent started: polling Gmail every "
            + pollingIntervalSeconds.toString() + " seconds");
}

# Loads the sample Stratus product docs from the docs folder into the knowledge base.
# + return - an error if the docs could not be loaded or ingested
function ingestProductDocs() returns error? {
    file:MetaData[] entries = check file:readDir("docs");
    string[] docPaths = [];
    foreach file:MetaData entry in entries {
        if !entry.dir {
            docPaths.push(entry.absPath);
        }
    }
    if docPaths.length() == 0 {
        log:printWarn("No product docs found in the docs folder; searchProductDocs will have nothing to retrieve");
        return;
    }
    ai:TextDataLoader loader = check new (...docPaths);
    ai:Document[]|ai:Document loadResult = check loader.load();
    check productDocsKnowledgeBase.ingest(loadResult);
    log:printInfo("Ingested " + docPaths.length().toString() + " product doc(s) into the knowledge base");
}
