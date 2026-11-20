import ballerinax/ai.openai;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.chat;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

final openai:ModelProvider openaiModelprovider = check new (string `${openAiApiKey}`, openai:GPT_4O_MINI);
final sheets:Client sheetsClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: sheets:REFRESH_URL}});
final calendar:Client calendarClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: calendarClientAuthRefreshUrl}});
final gmail:Client gmailClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: gmailClientAuthRefreshUrl}});
final chat:Client frontDeskChatClient = check new ({auth: {path: googleServiceAccountFile}});
