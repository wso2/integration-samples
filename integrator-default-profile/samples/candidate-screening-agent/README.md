# Candidate Screening Agent

A voice agent that runs first-round phone screens for job applicants, built entirely in the WSO2 Agent Builder
diagram view: the agent, tools, connections and triggers were added from the UI, with no hand-written code.

The agent asks which role the candidate is applying for and matches it to the open roles in a Google Sheet. It asks
about each of the role's must-haves, the start date, the location and work mode, and the expected salary. Then it
scores the candidate from 1 to 5 and records the screening in the sheet. Candidates who advance are offered free
interview slots from Google Calendar, the slot they pick is booked, and Gmail sends them a confirmation. The agent
never tells candidates their score and doesn't ask about protected characteristics such as age or marital status.

Candidates talk to the agent by voice, or by text through the Agent Chat endpoint.

## What's in the project

Open the folder in WSO2 Agent Builder to see each part in the diagram view.

**Agent.** `screeningAgent` uses the `openaiModelprovider` model (OpenAI gpt-4o-mini) and short-term memory, so each
call remembers what the candidate already said. Its instructions describe how a screen goes and keep every reply to one
to three short sentences with no lists or symbols, because replies are spoken aloud. **Max Iterations** is set to 20,
so the agent can score, record and look up interview slots in one turn.

**Tools.** The agent has seven tools:

| Tool | Added from | What it does |
|---|---|---|
| `listOpenRoles` | Google Sheets → Get range | Reads the open roles from the Roles sheet |
| `recordScreening` | Google Sheets → Append value | Adds the screening result to the Screenings sheet |
| `listCalendarEvents` | Google Calendar → Get events response | Lists interview calendar events in a time range |
| `bookInterview` | Google Calendar → Create event | Books a 45-minute interview |
| `emailCandidate` | Gmail → Send message | Emails the candidate the interview confirmation |
| `getCurrentTime` | time → utcNow | Gets the current time |
| `toLocalTime` | time → utcToCivil | Turns a time into the local date and day of the week (UTC+05:30) |

Every tool's parameters and return value are described in its **Edit** form, and the agent sees those descriptions.

**Triggers.**

| Trigger | Listener | Port |
|---|---|---|
| Voice Chat (`onChatMessage`) | `voiceListener` (`CloudVoiceListener`) | 8080 |
| Agent Chat (`/screening-agent`, used by **Try It**) | `agentChatListener` | 9090 (default listener) |

## Setup

### Google Sheets, Calendar and Gmail

1. Create a spreadsheet with two worksheets:
   - **Roles**, with the header row
     `Role ID | Title | Must-haves | Location and work mode | Salary range (LKR per month) | Hiring manager`,
     and one row per open role, for example
     `DAT-310 | Data Analyst | SQL; Excel or Google Sheets; a BI tool such as Power BI or Looker; degree in a quantitative field | Remote within Sri Lanka | 180,000 - 280,000 | Ruwan Silva`.
   - **Screenings**, with the header row
     `Logged at | Candidate | Phone | Email | Role ID | Summary | Score (1-5) | Outcome`.
2. Create a Google Calendar for interviews and copy its **Calendar ID** from its settings.
3. In Google Cloud, enable the Sheets, Calendar and Gmail APIs. Create an OAuth client (Web application, redirect URI
   `https://developers.google.com/oauthplayground`), add yourself as a test user, and get a refresh token from the
   OAuth Playground with the `spreadsheets`, `calendar` and `gmail.send` scopes.

### Run

1. Open the folder in WSO2 Agent Builder.
2. Copy `Config.toml.example` to `Config.toml` and fill in every value.
3. Select **Run**. Use the **Try It** chat to test as a candidate, or send a request to the chat endpoint:

   ```bash
   curl -X POST http://localhost:9090/screening-agent/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "candidate-1", "message": "Hi, I would like to apply for the Data Analyst role."}'
   ```

4. To talk to the agent by voice, deploy it as an AI agent in **WSO2 Cloud** and select **Enable Voice Agent** on the
   agent's overview page. The voice agent connects to the voice listener on port 8080.

## Make it yours

- **Roles:** add, change or remove rows in the Roles sheet. The agent reads them on every call.
- **Time zone and interview hours:** edit the agent's instructions and the `toLocalTime` tool's offset (19800 seconds
  is UTC+05:30).
- **More tools:** in the agent's view, select **Add Tool** and pick a connector action or a function.
