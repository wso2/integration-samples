import ballerina/log;
import ballerinax/hubspot.crm.associations.schema;

public function main() returns error? {
    do {
        schema:CollectionResponsePublicAssociationDefinitionUserConfigurationNoPaging result = check schemaClient->/definitions/configurations/all.get();
        log:printInfo(result.toJsonString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
