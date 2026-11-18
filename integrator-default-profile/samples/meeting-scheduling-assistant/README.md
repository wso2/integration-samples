# Meeting scheduling assistant

This sample books meetings on Google Calendar. The agent reads a colleague's events for a requested day, computes free slots within work hours, and creates the event after the requester confirms a slot.

The agent writes to Google Calendar only after an explicit confirmation. It doesn't reschedule or cancel events.

## Prerequisites

- Ballerina `2201.14.1` and WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Google Cloud project with the Google Calendar API turned on.
- A Google Cloud OAuth 2.0 client ID and secret, and a refresh token that grants the `https://www.googleapis.com/auth/calendar` scope. You can get the refresh token from the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) by using your own client credentials.
- Access to the colleague's calendar. The signed-in Google account must see the colleague's event times and be able to create events on that calendar. To try the sample alone, use your own email address as the colleague.

## Configuration

Create `Config.toml` in the sample directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Google Calendar values yourself:

```toml
calendarClientId = "GOOGLE_CLIENT_ID"
calendarClientSecret = "GOOGLE_CLIENT_SECRET"
calendarRefreshToken = "GOOGLE_REFRESH_TOKEN"

[ballerina.ai.wso2ProviderConfig]
serviceUrl = "SERVICE_URL"
accessToken = "ACCESS_TOKEN"
```

Replace the following:

- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REFRESH_TOKEN`: your OAuth 2.0 credentials.
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. This sample does not need an embedding provider.

The client requests an access token at startup, so the integration doesn't start with invalid Google credentials. Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from this directory.
3. Ask for a slot:

   ```bash
   curl -X POST http://localhost:9090/meeting-scheduling-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"meeting-1","message":"Find a 30-minute slot with kai@example.com next Thursday afternoon. My time zone is America/New_York."}'
   ```

   Replace `kai@example.com` with a calendar you can access. The agent lists the colleague's events for that day and proposes free slots between 12 PM and 5 PM. It doesn't book anything yet.

4. Confirm one of the proposed slots with the same `sessionId`:

   ```bash
   curl -X POST http://localhost:9090/meeting-scheduling-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"meeting-1","message":"Book the first slot and call it Project sync."}'
   ```

   The agent creates the event with the colleague as an attendee and returns the booked time and the event link. Google Calendar doesn't email the invitation because the tool doesn't request notifications.

A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `meetingSchedulingAgent`

Finds free slots on a colleague's Google Calendar within 9 AM to 5 PM and books the slot that the requester confirms. It never books an overlapping slot or books without confirmation.

- **Query:** the colleague's email address, the meeting duration, and the day and time window, for example `Find a 30-minute slot with kai@example.com next Thursday afternoon`. The service adds today's date (UTC) to every request so relative days such as "Thursday" resolve correctly.
- **Response:** a `string` with the proposed slots or, after confirmation, the booked time and the event link. The agent asks for the colleague's email address or the duration if either is missing.
- **Tools:** `listBusySlots`, `findFreeSlots`, `createMeetingEvent`.
- **Initialization parameters:** `model`, the model provider the agent uses.

## How it works

- `agents.bal` defines the scheduling instructions and three tools.
- `connections.bal` creates the Google Calendar client from the OAuth 2.0 configuration.
- `listBusySlots` reads the calendar's events between two timestamps, expanding recurring events, and returns their start and end times.
- `findFreeSlots` takes the local midnight of the day, adds work hours from 9 AM to 5 PM, and returns back-to-back slots of the requested length that don't overlap a busy slot. After an overlap, it tries again 15 minutes later. It rejects a duration that isn't positive.
- `createMeetingEvent` creates the event with the confirmed times, time zone, and attendees, and returns the event ID and link.
- `automation.bal` adds today's date to the request and exposes `POST /meeting-scheduling-assistant/chat` through the AI listener.

## Limitations

- `listBusySlots` ignores all-day events, such as a day marked out of office, and doesn't check whether an event is marked free.
- The sample checks one colleague's calendar. It doesn't find a common slot across several calendars.
- The model converts the requested day to timestamps. On days when daylight saving time changes, the work-hour window shifts by one hour.
- The agent doesn't handle recurring meetings, rescheduling, or cancellation.

The model chooses which calendar to read and write. Authenticate requesters and restrict the calendars that the agent can access before you deploy it.
