import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis.chat;
import ballerinax/telegram;
import ballerinax/whatsapp.business;

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /appointment\-agent on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string stringResult = check appointmentAgent.run(request.message, "web:" + request.sessionId);
        return {message: stringResult};
    }
}

listener business:Listener businessListener = new (8090, verifyToken = whatsappVerifyToken, appSecret = whatsappAppSecret);

service business:WhatsAppService on businessListener {
    final business:Client whatsappClient;

    function init() returns error? {
        self.whatsappClient = check new ({auth: {token: whatsappAccessToken}});
    }

    remote function onMessages(business:MessagesNotification notification) returns error? {
        if notification is business:Messages {
            _ = start self.replyToWhatsAppMessages(notification);
        }
    }

    function replyToWhatsAppMessages(business:Messages notification) {
        foreach business:InboundMessage message in notification.messages {
            string replyText;
            string? text = message.text;
            if text is () {
                replyText = "Sorry, I can only handle text messages right now.";
            } else {
                string|error result = appointmentAgent.run(text, sessionId = "whatsapp:" + message.'from);
                if result is error {
                    log:printError("Agent run failed", result);
                    replyText = "Sorry, something went wrong. Please try again.";
                } else {
                    replyText = result;
                }
            }
            business:TextMessage payload = {to: message.'from, text: {body: replyText, previewUrl: false}};
            business:MessageResponsePayload|business:Error sent =
                    self.whatsappClient->sendMessage(notification.phoneNumberId, payload);
            if sent is business:Error {
                log:printError("WhatsApp send failed", sent);
            }
        }
    }
}

listener telegram:Listener telegramListener = new (8091, accessToken = telegramBotToken, callbackUrl = telegramCallbackUrl, serviceUrl = "https://api.telegram.org");

service telegram:TelegramService on telegramListener {
    final telegram:Client telegramClient;

    function init() returns error? {
        self.telegramClient = check new ({accessToken: telegramBotToken});
    }

    remote function onMessage(telegram:Message message) returns error? {
        _ = start self.replyToTelegramMessage(message);
    }

    function replyToTelegramMessage(telegram:Message message) {
        string replyText;
        string? text = message.text;
        if text is () {
            replyText = "Sorry, I can only handle text messages right now.";
        } else {
            string|error result = appointmentAgent.run(text, sessionId = "telegram:" + message.chat.id.toString());
            if result is error {
                log:printError("Agent run failed", result);
                replyText = "Sorry, something went wrong. Please try again.";
            } else {
                replyText = result;
            }
        }
        telegram:Message|error sent = self.telegramClient->sendMessage(message.chat.id, replyText);
        if sent is error {
            log:printError("Telegram send failed", sent);
        }
    }
}

listener chat:Listener chatListener = new (8000, auth = {path: googleServiceAccountFile});

@chat:ServiceConfig {
    endpointUrl: googleChatEndpointUrl
}
service chat:ChatService on chatListener {
    remote function onMessage(chat:MessageEvent event, chat:MessageCaller caller)
            returns error? {
        if (event.space?.name ?: "") != "spaces/" + frontDeskSpaceId {
            check caller->respond({text: "Sorry, this assistant only works in the clinic front desk space."});
            return;
        }
        check caller->respond();
        _ = start self.replyToChatMessage(event, caller);
    }

    function replyToChatMessage(chat:MessageEvent event, chat:MessageCaller caller) {
        string replyText;
        string? text = event.message.text;
        if text is () {
            replyText = "Sorry, I can only handle text messages right now.";
        } else {
            string|error result = frontDeskAgent.run(text, sessionId = "googlechat:" + (event.space?.name ?: "unknown"));
            if result is error {
                log:printError("Agent run failed", result);
                replyText = "Sorry, something went wrong. Please try again.";
            } else {
                replyText = result;
            }
        }
        chat:CreateMessageRequest reply = {text: replyText};
        chat:ChatThread? thread = event.message.thread;
        if thread is chat:ChatThread {
            reply.thread = thread;
        }
        chat:Message|error sent = caller->sendMessage(reply);
        if sent is error {
            log:printError("Google Chat send failed", sent);
        }
    }
}

