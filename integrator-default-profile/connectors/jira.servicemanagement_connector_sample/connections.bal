import ballerinax/jira.servicemanagement;

final servicemanagement:Client servicemanagementClient = check new ({auth: {username: servicemanagementEmail, password: servicemanagementApiToken}}, string `${servicemanagementServiceUrl}`);
