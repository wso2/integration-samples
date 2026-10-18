import ballerina/ftp;

final ftp:Client ftpClient = check new ({protocol: ftp:SFTP, host: "localhost", port: 2222, auth: {credentials: {username: sftpUsername, password: sftpPassword}}});
