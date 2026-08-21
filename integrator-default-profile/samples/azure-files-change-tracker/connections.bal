import ballerinax/azure.storage.files;

// The tracker lists the share and stores its snapshot through this client.
final files:Client shareClient = check new (shareName, auth = {accountName, accountKey});
