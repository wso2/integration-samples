import ballerina/email;

final email:SmtpClient emailSmtpClient = check new (emailHost, emailUsername, emailPassword, port = emailPort, security = email:SSL);
