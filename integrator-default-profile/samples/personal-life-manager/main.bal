import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerinax/telegram;

listener telegram:Listener telegramListener = new (8090,
    accessToken = telegramBotToken,
    callbackUrl = telegramCallbackUrl
);

service telegram:TelegramService on telegramListener {
    final telegram:Client telegramClient;

    function init() returns error? {
        self.telegramClient = check new ({accessToken: telegramBotToken});
    }

    remote function onMessage(telegram:Message message) returns error? {
        // Ignore messages from chats other than the configured allowed chat
        if message.chat.id != allowedChatId {
            return;
        }
        _ = start self.replyToTelegramMessage(message);
    }

    function replyToTelegramMessage(telegram:Message message) {
        // Reply directly for unsupported message types (stickers, photos, etc.) — not an error condition
        if message.text is () && message.voice is () {
            telegram:Message|error sent = self.telegramClient->sendMessage(
                message.chat.id, "Sorry, I only understand text and voice messages.");
            if sent is error {
                log:printError("Telegram sendMessage failed", sent);
            }
            return;
        }

        string sessionId = "telegram:" + message.chat.id.toString();
        string|error input = self.extractMessageText(message);
        string replyText;
        if input is error {
            log:printError("Failed to extract message text", input);
            replyText = "Sorry, I could not process your message. Please try again.";
        } else {
            string|error result = ariaAgent.run(input, sessionId = sessionId);
            if result is error {
                log:printError("Agent run failed", result);
                replyText = "Sorry, something went wrong. Please try again.";
            } else {
                replyText = result;
            }
        }
        telegram:Message|error sent = self.telegramClient->sendMessage(message.chat.id, replyText);
        if sent is error {
            log:printError("Telegram sendMessage failed", sent);
        }
    }

    function extractMessageText(telegram:Message message) returns string|error {
        string? text = message.text;
        if text is string {
            return text;
        }

        telegram:Voice? voice = message.voice;
        if voice is telegram:Voice {
            byte[] audioBytes = check self.telegramClient->downloadFile(voice.file_id);

            mime:Entity filePart = new;
            mime:ContentDisposition cd = new;
            cd.name = "file";
            cd.fileName = "voice.ogg";
            cd.disposition = "form-data";
            filePart.setContentDisposition(cd);
            _ = check filePart.setContentType("audio/ogg");
            filePart.setByteArray(audioBytes);

            mime:Entity modelPart = new;
            mime:ContentDisposition mcd = new;
            mcd.name = "model";
            mcd.disposition = "form-data";
            modelPart.setContentDisposition(mcd);
            modelPart.setText("whisper-large-v3");

            http:Request audioReq = new;
            audioReq.setBodyParts([filePart, modelPart], mime:MULTIPART_FORM_DATA);

            http:Response audioResp = check groqAudioClient->post("/openai/v1/audio/transcriptions", audioReq);
            if audioResp.statusCode != 200 {
                string errBody = check audioResp.getTextPayload();
                log:printError("Groq transcription failed", statusCode = audioResp.statusCode, body = errBody);
                return error("Voice transcription failed. Please try again.");
            }
            json respJson = check audioResp.getJsonPayload();
            return (check respJson.text).toString();
        }

        return error("Unsupported message type. Please send text or a voice message.");
    }
}
