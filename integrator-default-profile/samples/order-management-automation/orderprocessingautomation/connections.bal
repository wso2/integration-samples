import orderprocessingautomation.ordersdb;

import ballerina/email;

final ordersdb:Client ordersDB = check new (ordersDBHost, ordersDBPort, ordersDBUser, ordersDBPassword, ordersDBDatabase);

final email:SmtpClient emailSmtpclient = check new (string `${emailHost}`, string `${emailUserName}`, string `${emailPassword}`, port = emailPort, security = "START_TLS_NEVER");
