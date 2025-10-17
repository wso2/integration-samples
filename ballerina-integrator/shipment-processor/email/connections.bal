import ballerina/email;

// SMTP client for sending emails
email:SmtpClient smtpClient = check new (
    host = smtpHost,
    username = smtpUsername,
    password = smtpPassword
);