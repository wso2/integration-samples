import ballerinax/azure.storage.files;

final files:Client azFilesClient = check new (shareName, auth = {accountName, accountKey});
