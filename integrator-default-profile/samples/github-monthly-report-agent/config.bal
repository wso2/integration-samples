# GitHub token that can read the issues and pull requests of the repository.
configurable string githubToken = ?;
# Owner of the GitHub repository to report on, such as wso2.
configurable string repoOwner = ?;
# Name of the GitHub repository to report on, such as integration-samples.
configurable string repoName = ?;

# OAuth client ID of the Google Cloud project that has the Gmail API enabled.
configurable string gmailClientId = ?;
# OAuth client secret of the Google Cloud project that has the Gmail API enabled.
configurable string gmailClientSecret = ?;
# OAuth refresh token for the Gmail account that sends the report.
configurable string gmailRefreshToken = ?;
# Token endpoint used to refresh the Gmail access token.
configurable string gmailRefreshUrl = "https://oauth2.googleapis.com/token";

# Email address that receives the monthly report.
configurable string recipientEmail = ?;
# Subject line of the report email.
configurable string emailSubject = "Monthly GitHub report";
