import ballerina/log;
import ballerinax/trello;

public function main() returns error? {
    do {
        trello:Card trelloCard = check trelloClient->/cards.post(idList = string `${trelloListId}`, name = "Integration Test Card", desc = "Sample card created by Trello connector integration");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
