import ballerinax/ai.openai;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.gmail;
import ballerinax/googleapis.sheets;

const string GOOGLE_OAUTH_REFRESH_URL = "https://oauth2.googleapis.com/token";

final openai:ModelProvider openaiModelprovider = check new (openAiApiKey, openai:GPT_4O_MINI);
final sheets:Client sheetsClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: GOOGLE_OAUTH_REFRESH_URL}});
final calendar:Client calendarClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: GOOGLE_OAUTH_REFRESH_URL}});
final gmail:Client gmailClient = check new ({auth: {clientId: googleClientId, clientSecret: googleClientSecret, refreshToken: googleRefreshToken, refreshUrl: GOOGLE_OAUTH_REFRESH_URL}});
