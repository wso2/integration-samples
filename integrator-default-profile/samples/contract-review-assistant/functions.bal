import ballerina/ai;
import ballerina/log;

// Loads the contract playbook into the knowledge base when the integration starts.
final boolean playbookLoaded = check loadPlaybook();

# Loads the contract playbook into the knowledge base. The playbook is a Markdown file, so the knowledge base splits
# it at its headings, and each clause's rules are retrieved together.
#
# + return - `true` once the playbook is loaded, or an error if it cannot be read or loaded
function loadPlaybook() returns boolean|error {
    ai:TextDataLoader loader = check new (playbookPath);
    ai:Document|ai:Document[] playbook = check loader.load();
    check playbookKnowledgeBase.ingest(playbook);
    log:printInfo("Loaded the contract playbook into the knowledge base", path = playbookPath);
    return true;
}
