import ballerina/ai;

public function main() returns error? {
    ai:TextDataLoader loader = check new ai:TextDataLoader("resources/product-catalog.md");
    ai:Document|ai:Document[] catalogDocuments = check loader.load();
    check productCatalogKnowledgeBase.ingest(catalogDocuments);
}
