import ballerina/http;
import ballerinax/googleapis.gmail;

final gmail:Client gmailClient = check new ({auth: {clientId: gmailClientId, clientSecret: gmailClientSecret, refreshToken: gmailRefreshToken}});
final http:Client ipQualityScoreClient = check new ("https://ipqualityscore.com/api/json/ip");
final http:Client ipApiClient = check new ("http://ip-api.com/json");
final http:Client gmailApiClient = check new ("https://gmail.googleapis.com/gmail/v1", auth = {refreshUrl: "https://oauth2.googleapis.com/token", refreshToken: gmailRefreshToken, clientId: gmailClientId, clientSecret: gmailClientSecret});
