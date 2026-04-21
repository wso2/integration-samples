import ballerina/email;

final email:SmtpClient emailSmtpclient = check new (string `${emailHost}`, string `${emailUsername}`, string `${emailPassword}`, port = emailPort, security = "SSL");
