import ballerinax/jira;

final jira:Client jiraAdapter = check new ({
    auth: {
        username: username,
        password: password
    }
}, "http://wso2.jira.com.balmock.io");
