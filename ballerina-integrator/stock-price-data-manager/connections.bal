import ballerina/ftp;
import ballerina/http;

final http:Client httpClient = check new ("https://www.alphavantage.co/");
final ftp:Client ftpClient = check new ({host: ftpHost, port: ftpPort, auth: {credentials: {username: ftpUserName, password: ftpPassword}}});
