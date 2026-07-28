import daily_summary.orderhub;

import ballerina/email;

final orderhub:Client dbClient = check new (dbClientHost, dbClientPort, dbClientUser, dbClientPassword, dbClientDatabase);

final email:SmtpClient emailSmtpclient = check new (string `${smtpHost}`, string `${smtpUser}`, string `${smtpPassword}`, port = smtpPort, security = "START_TLS_NEVER");
