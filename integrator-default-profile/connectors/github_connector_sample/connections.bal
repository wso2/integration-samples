import ballerinax/github;

final github:Client githubClient = check new ({auth: {token: githubAuthToken}});
