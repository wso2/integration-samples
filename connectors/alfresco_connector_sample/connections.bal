import ballerinax/alfresco;

final alfresco:Client alfrescoClient = check new ({auth: {username: alfrescoUsername, password: alfrescoPassword}}, string `${alfrescoServiceUrl}`);
