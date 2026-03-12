import ballerinax/jira;
import ballerinax/mailchimp.'transactional as mailchimp;

final jira:Client jiraClient = check new ({
    auth: {
        username: jiraConfig.username,
        password: jiraConfig.password
    }
}, getJiraApiUrl());

final mailchimp:Client mailchimpClient = check new ();

