# Personal Life Manager

## Description

A personal life manager that you chat with on Telegram, powered by an AI agent named **Aria**. It checks your Gmail inbox for unread emails, fetches your Google Calendar events for any date, lists your pending Google Tasks, and creates new tasks for you. Text messages go straight to Aria; voice notes are first transcribed by Groq Whisper, so you can speak naturally instead of typing. This sample shows how to build a voice- and text-capable AI agent in Ballerina that connects Telegram to real Google services.

## How It Works

```mermaid
%%{init: {'flowchart': {'curve': 'basis'}}}%%
flowchart LR
    User(["👤 User"])

    subgraph Telegram["Telegram"]
        TGApp["📱 Telegram App"]
        Ngrok["🌐 ngrok tunnel"]
    end

    subgraph Voice["Voice Processing"]
        Whisper["🎙️ Groq Whisper\nwhisper-large-v3"]
    end

    subgraph Ballerina["Agent Builder"]
        TGSvc["⚡ TG Svc"]
        Agent["🤖 Aria"]
    end

    subgraph Google["Google Services"]
        Gmail["📧 Gmail API\ngetUnreadEmails"]
        GCal["📅 Google Calendar API\ngetCalendarEvents"]
        GTasks["✅ Google Tasks API\ncreateTask / getTasks"]
    end

    %% User & Telegram Flow
    User -- "text / voice msg" --> TGApp
    TGApp -- "webhook POST" --> Ngrok
    Ngrok -- "forward" --> TGSvc
    TGSvc -- "sendMessage" --> TGApp
    TGApp -- "message" --> User

    %% Voice Transcription Flow (Cleanly underneath)
    TGSvc -- "voice: OGG audio" --> Whisper
    Whisper -- "transcript" --> TGSvc

    %% Agent & LLM Orchestration
    TGSvc -- "msg" --> Agent
    Agent -- "reply"  --> TGSvc

    %% External Google Tools
    Agent -- "getUnreadEmails" --> Gmail
    Agent -- "getCalendarEvents" --> GCal
    Agent -- "createTask / getTasks" --> GTasks

    %% Node Styling
    classDef userNode fill:#D6EAF8,stroke:#2AABEE,stroke-width:3px,color:#1A5276
    classDef telegramNode fill:#D6EAF8,stroke:#2AABEE,stroke-width:2px,color:#1A5276
    classDef agentNode fill:#EDE7F6,stroke:#7E57C2,stroke-width:2px,color:#4A235A
    classDef voiceNode fill:#E8F5E9,stroke:#43A047,stroke-width:2px,color:#1B5E20
    classDef googleNode fill:#FFF8E1,stroke:#FFB300,stroke-width:2px,color:#7D5A00

    class User userNode
    class TGApp,Ngrok telegramNode
    class TGSvc,Agent agentNode
    class Whisper voiceNode
    class Gmail,GCal,GTasks googleNode

    %% Subgraph Styling
    style Telegram fill:#EBF5FB,stroke:#2AABEE,stroke-width:2px,color:#1A5276
    style Ballerina fill:#F4ECF7,stroke:#7E57C2,stroke-width:2px,color:#4A235A
    style Voice fill:#EAFAF1,stroke:#43A047,stroke-width:2px,color:#1B5E20
    style Google fill:#FFFDE7,stroke:#FFB300,stroke-width:2px,color:#7D5A00
```

## Prerequisites

- ngrok — [download for your OS](https://ngrok.com/download) or `brew install ngrok` on Mac
- A Telegram bot token from [@BotFather](https://t.me/botfather)
- A Google Cloud project with **Gmail API**, **Google Calendar API**, and **Google Tasks API** enabled, and an OAuth 2.0 refresh token with all three scopes
- A Groq API key from [console.groq.com](https://console.groq.com)
- WSO2 Integrator, with the default WSO2 model provider configured. In WSO2 Integrator, run the **Configure default WSO2 model provider** command. It adds the provider's settings to `Config.toml`.

### Getting OAuth2 tokens for Google APIs

1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable **Gmail API**, **Google Calendar API**, and **Google Tasks API**
3. Create OAuth 2.0 credentials (Desktop app type)
4. Use the OAuth Playground and include these scopes when authorizing:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/calendar.readonly`
   - `https://www.googleapis.com/auth/tasks`
5. Exchange for a refresh token and use it for `googleRefreshToken` (one token covers Gmail, Calendar, and Tasks)

### Finding your Telegram chat ID

**Option 1 — getUpdates API**

1. Start your bot in Telegram and send it any message (e.g. "hello")
2. Open this URL in a browser (replace `<BOT_TOKEN>` with your bot token):
   ```
   https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
   ```
3. Find `"chat":{"id":XXXXXXXXX}` in the response — that number is your `allowedChatId`

**Option 2 — @userinfobot**

1. Open Telegram and search for [@userinfobot](https://t.me/userinfobot)
2. Send it `/start`
3. It replies with your user ID — that's also your private chat ID with any bot

## Configuration

Provide the configuration through a `Config.toml` file in the sample root:

```toml
# Telegram
telegramBotToken = "<your bot token from BotFather>"
telegramCallbackUrl = "https://<your-ngrok-subdomain>.ngrok-free.app"

# Google OAuth2 — single set of credentials for Gmail, Calendar, and Tasks
googleClientId     = "<Google Cloud client ID>"
googleClientSecret = "<Google Cloud client secret>"
googleRefreshToken = "<OAuth2 refresh token>"
calendarId         = "primary"
tasksListId        = "@default"

# Allowed Telegram chat ID (your personal chat ID — prevents unauthorized access)
allowedChatId = <your_chat_id>

# Groq API (free tier — voice transcription via Whisper)
groqApiKey = "<your Groq API key>"

# Added by the "Configure default WSO2 model provider" command.
[ballerina.ai.wso2ProviderConfig]
serviceUrl  = "<SERVICE_URL>"
accessToken = "<ACCESS_TOKEN>"
```

## Usage Instructions

### Option 1 — Using `start.sh` (recommended)

Run this once from the project root. It kills stale processes, starts ngrok, auto-updates `telegramCallbackUrl` in `Config.toml`, and starts the agent:

```bash
chmod +x start.sh   # only needed the first time
./start.sh
```

### Option 2 — Manual steps (without `start.sh`)

1. Start ngrok in a separate terminal:

   ```bash
   ngrok http 8090
   ```

2. Copy the `https://xxxx.ngrok-free.app` URL shown by ngrok. Open `Config.toml` in the sample root and update:

   ```toml
   telegramCallbackUrl = "https://xxxx.ngrok-free.app"
   ```

3. Start the agent in a second terminal:

   ```bash
   cd <sample-root>
   bal run
   ```

---

### Talking to Aria

Once the agent is running, open Telegram, find your bot, and try any of these:

1. **Check unread emails:**

   ```
   What are my unread emails?
   ```

   Aria fetches your Gmail inbox and lists up to 10 unread messages with sender, subject, and snippet.

2. **Check today's calendar:**

   ```
   What's on my calendar today?
   ```

   Aria returns all events for the current date with start and end times.

3. **Check a specific date:**

   ```
   Any meetings on 2026-11-20?
   ```

   Aria fetches events for that date only.

4. **Create a task:**

   ```
   Add a task: Review project proposal, due 2026-11-20
   ```

   Aria creates the task in Google Tasks and confirms.

5. **List pending tasks:**

   ```
   What are my pending tasks?
   ```

   Aria lists all incomplete tasks with their due dates.

6. **Send a voice note:**

   Record any of the above as a voice message in Telegram and send it. Aria transcribes it with Groq Whisper and responds the same way as a text message.
