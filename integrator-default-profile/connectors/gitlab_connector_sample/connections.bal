import ballerinax/gitlab;

final gitlab:Client gitlabClient = check new ({auth: {privateToken: gitlabToken}}, string `${gitlabServiceUrl}`);
