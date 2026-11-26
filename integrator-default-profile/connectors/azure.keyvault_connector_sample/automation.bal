import ballerina/log;
import ballerinax/azure.keyvault;

public function main() returns error? {
    do {
        keyvault:SecretListResult secrets = check keyvaultClient->listSecrets(apiVersion = "7.0");
        log:printInfo(secrets.toString());
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
