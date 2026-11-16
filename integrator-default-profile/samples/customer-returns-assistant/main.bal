import ballerina/ai;

public function main() returns error? {
    ai:TextDataLoader loader = check new ai:TextDataLoader("resources/return-policy.md");
    ai:Document|ai:Document[] policyDocuments = check loader.load();
    check returnPolicyKnowledgeBase.ingest(policyDocuments);
}
