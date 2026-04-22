import ballerinax/jira;

final jira:Client jiraClient = check new ({auth: {token: jiraToken}}, string `${jiraServiceUrl}`);
