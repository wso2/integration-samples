# Clinic Appointment Agent

An appointment desk for a medical clinic, built entirely in the WSO2 Agent Builder diagram view: agents, tools,
connections and triggers were added from the UI, with no hand-written code.

- **`appointmentAgent`** serves patients on **WhatsApp**, **Telegram**, and web chat. It identifies the patient,
  registers new patients, suggests a doctor, finds free slots, and books, reschedules, or cancels appointments.
- **`frontDeskAgent`** serves reception staff in **Google Chat**. Staff can see a day's schedule, book or cancel for
  patients who call or walk in, and email patients.

Appointments are Google Calendar events on one clinic calendar, the patient register is a Google Sheet, and Gmail
sends emails.

![Clinic Appointment Agent architecture: patients on WhatsApp, Telegram and Agent Chat reach appointmentAgent, front desk staff on Google Chat reach frontDeskAgent after a front desk space check, and both agents share tools for Google Sheets, Google Calendar, Gmail, Google Chat and time](images/architecture.png)

## What's in the project

Open the folder in WSO2 Agent Builder to see each part in the diagram view.

**Agents.** Both agents use the `openaiModelprovider` model (OpenAI gpt-4o-mini) and short-term memory, so each chat
remembers what was already said. Their instructions describe the clinic's doctors and hours, how to identify a
patient, and how to book.

**Tools.** Both agents share nine tools:

| Tool | Added from | What it does |
|---|---|---|
| `readPatientRegister` | Google Sheets → Get range | Reads every row of the Patients sheet |
| `registerPatient` | Google Sheets → Append value | Adds a row to the Patients sheet |
| `listClinicEvents` | Google Calendar → Get events response | Lists calendar events in a time range |
| `bookAppointmentEvent` | Google Calendar → Create event | Books an appointment as a calendar event |
| `cancelAppointmentEvent` | Google Calendar → Delete event | Cancels an appointment |
| `emailPatient` | Gmail → Send message | Emails a patient |
| `getCurrentTime` | time → utcNow | Gets the current time |
| `toCalendarDate` | time → utcToCivil | Turns a time into a calendar date and day of the week |
| `notifyFrontDesk` | Google Chat → Create a message | Posts a booking or cancellation alert to the front desk space |

Both agents' instructions tell them to call `notifyFrontDesk` after every booking and cancellation. Every tool's
parameters and return value are described in its **Edit** form, and the agent sees those descriptions.

**Front desk space check.** The Google Chat trigger's `onMessage` flow has an **If** node: a message from any space
other than `frontDeskSpaceId` gets a refusal reply and never reaches `frontDeskAgent`, because the front desk agent
can see every patient's bookings.

**Triggers.** Each trigger listens on its own port:

| Trigger | Agent | Listener | Port |
|---|---|---|---|
| Agent Chat (`/appointment-agent`, used by **Try It**) | `appointmentAgent` | `agentChatListener` | 9090 (default listener) |
| WhatsApp | `appointmentAgent` | `businessListener` | 8090 |
| Telegram | `appointmentAgent` | `telegramListener` | 8091 |
| Google Chat | `frontDeskAgent` | `chatListener` | 8000 |

## Setup

### Google Calendar, Sheets and Gmail

1. Create a Google Calendar for appointments and copy its **Calendar ID** from its settings.
2. Create a spreadsheet with a worksheet named **Patients**, with the header row
   `Mobile | Name | Email | Date of birth`. Enter mobile numbers as text, in international format.
3. In Google Cloud, enable the Calendar, Sheets and Gmail APIs. Create an OAuth client (Web application, redirect URI
   `https://developers.google.com/oauthplayground`), add yourself as a test user, and get a refresh token from the
   OAuth Playground with the `calendar`, `spreadsheets` and `gmail.send` scopes.

### Public URLs for the channels

WhatsApp, Telegram and Google Chat each need a public HTTPS URL that forwards to their listener's port, for example
an ngrok tunnel per port:

- **WhatsApp (8090):** set the Meta webhook callback URL to the public URL with your verify token, and subscribe
  to `messages`.
- **Telegram (8091):** set `telegramCallbackUrl` to the public URL. The webhook is registered on startup.
- **Google Chat (8000):** set the Chat app's HTTP endpoint URL (and authentication audience) to the public URL, and
  set `googleChatEndpointUrl` to the same value.

### Google Chat (front desk)

1. Enable the Google Chat API. Under **Configuration**, leave **Build this Chat app as a Google Workspace add-on**
   unticked, turn on interactive features, and choose **HTTP endpoint URL**.
2. Create a service account in the same project, add a JSON key, and set `googleServiceAccountFile` to its path.
3. Add the app to the front desk's space and set `frontDeskSpaceId` to the space ID from its URL (the part after
   `spaces/` or `room/`). The same service account posts the booking alerts there.

### Run

1. Open the folder in WSO2 Agent Builder.
2. Copy `Config.toml.example` to `Config.toml` and fill in every value.
3. Select **Run**. Use the **Try It** chat to test as a patient.

## Make it yours

- **Doctors and hours:** edit the doctors in each agent's instructions.
- **More tools:** in an agent's view, select **Add Tool** and pick a connector action or a function.
- **Voice:** add a voice trigger to `appointmentAgent` from **Add Trigger**, so patients can book by phone.
