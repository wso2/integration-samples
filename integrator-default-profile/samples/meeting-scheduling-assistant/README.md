# Meeting scheduling assistant

This sample books meetings on Google Calendar. The agent reads a colleague's events for a requested day, finds free slots within work hours, and creates the event after the requester confirms a slot and approves the booking.

Every file in this sample comes from Choreo Agent Builder's forms: the agent, the Google Calendar connection and its configurables, four tools made from Google Calendar actions and standard library functions, the Agent Chat entry point, and its approval resource. You can build the same project in Agent Builder without writing code.

The booking tool requires approval, so the agent writes to Google Calendar only after the requester approves the call. It doesn't reschedule or cancel events.

## Prerequisites

- Ballerina `2201.14.2` and Choreo Agent Builder, or WSO2 Integrator with Agent Builder support.
- The default WSO2 model provider configured. In the command palette, run **Configure default WSO2 model provider** for this sample.
- A Google Cloud project with the Google Calendar API turned on.
- A Google Cloud OAuth 2.0 client ID and secret, and a refresh token that grants the `https://www.googleapis.com/auth/calendar` scope. You can get the refresh token from the [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) by using your own client credentials.
- Access to the colleague's calendar. The signed-in Google account must see the colleague's event times and be able to create events on that calendar. To try the sample alone, use your own email address as the colleague.

## Configuration

The sample is a workspace with one package, `meeting_scheduling_assistant`. Create `Config.toml` in the `meeting_scheduling_assistant` directory. The provider command adds the `[ballerina.ai.wso2ProviderConfig]` table; add the Google Calendar values yourself, above that table:

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
- `SERVICE_URL` and `ACCESS_TOKEN`: the values that the provider command writes. The model uses them.

Do not commit `Config.toml`.

## Run the sample

1. Open this sample directory in Choreo Agent Builder or WSO2 Integrator.
2. Run the integration with **Run**, or run `bal run` from the `meeting_scheduling_assistant` directory.
3. Ask for a slot:

   ```bash
   curl -X POST http://localhost:9090/meeting-scheduling-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"meeting-1","message":"Find a 30-minute slot with kai@example.com next Thursday afternoon. My UTC offset is -05:00."}'
   ```

   Replace `kai@example.com` with a calendar you can access. The agent lists the colleague's events for that day and proposes free slots between 12:00 and 17:00 in your offset. It doesn't book anything yet.

4. Confirm one of the proposed slots with the same `sessionId`:

   ```bash
   curl -X POST http://localhost:9090/meeting-scheduling-assistant/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"meeting-1","message":"Book the first slot and call it Project sync."}'
   ```

   The run pauses before the event is created. The service responds with HTTP `403` and a body that lists the pending approval request, for example:

   ```json
   {"requests":[{"id":"APPROVAL_ID","sessionId":"meeting-1","toolName":"createMeetingEvent","arguments":{"calendarId":"kai@example.com"}}]}
   ```

   The real response carries all the tool arguments and a few more fields.

5. Approve the booking with the `id` from that response:

   ```bash
   curl -X POST http://localhost:9090/meeting-scheduling-assistant/decision \
     -H "Content-Type: application/json" \
     -d '{"sessionId":"meeting-1","decisions":{"APPROVAL_ID":{"outcome":"APPROVE"}}}'
   ```

   The agent creates the event with the colleague as an attendee and returns the booked time and the event link. To decline, send `"outcome":"REJECT"` with an optional `"reason"`. The tool doesn't ask Google Calendar to send notifications, so the attendee usually gets no invitation email.

A response contains a `message` field; its wording depends on the model. Run one sample at a time because the samples use port `9090`.

## Agents

### `meetingSchedulingAgent`

Finds free slots on a colleague's Google Calendar between 9 AM and 5 PM in the requester's time zone, and books the slot that the requester confirms and approves.

- **Query:** the colleague's email address, the meeting duration, the day and time window, and the requester's UTC offset, for example `Find a 30-minute slot with kai@example.com next Thursday afternoon. My UTC offset is -05:00.`. Relative days such as "Thursday" work because the agent reads today's date (UTC) from a tool.
- **Response:** a `string` with the proposed slots or, after approval, the booked time and the event link. The agent asks for the colleague's email address, the duration, or the UTC offset if any is missing.
- **Tools:** `listEvents`, `getCurrentTime`, `formatTime`, `createMeetingEvent` (requires approval).
- **Model:** the default WSO2 model provider.

## How it works

All the code is in the `meeting_scheduling_assistant` package:

- `agents.bal` defines the agent and its four tools. The instructions hold the work hours and the steps the agent follows, including which tool to call at each step.
- `config.bal` declares the `calendarClientId`, `calendarClientSecret`, and `calendarRefreshToken` configurables.
- `connections.bal` creates the Google Calendar client, `googleCalendarClient`, from the `ballerinax/googleapis.gcalendar` connector with OAuth 2.0 refresh token authentication and the connector's default token endpoint.
- `main.bal` exposes `POST /meeting-scheduling-assistant/chat` for messages and `POST /meeting-scheduling-assistant/decision` for approval decisions on `agentChatListener`, the shared listener on port `9090`. The agent view shows one Agent Chat trigger for each resource.
- `automation.bal`, `data_mappings.bal`, `functions.bal`, and `types.bal` are empty files that Agent Builder creates with every project.

The tools wrap Google Calendar actions and standard library functions, so the model does the reasoning between them:

- `listEvents` calls the Google Calendar action that lists a calendar's events, with recurring events expanded into single events. The model passes the calendar ID and the start and end of the day as RFC 3339 timestamps with the requester's offset.
- `getCurrentTime` and `formatTime` wrap `time:utcNow` and `time:utcToString`. The agent reads today's date from the ISO 8601 string that `formatTime` returns and uses it to resolve relative days.
- `createMeetingEvent` calls the Google Calendar action that creates an event. The model passes the calendar ID and the event: its title, the start and end times with the requester's offset, and the colleague as an attendee. The `@ai:AgentTool` annotation sets `requiresApproval: true`, so every call pauses until the requester approves it.

The agent finds the free slots itself. It ignores events marked as free, treats an all-day event as busy for the whole day, and keeps only slots of the requested length between 09:00 and 17:00 that don't overlap a busy range.

`bal build` reports four `undocumented return parameter` warnings, one for each tool. Agent Builder doesn't write a return line in the documentation of the tools it generates. The warnings don't affect the build.

## Limitations

- The model finds the free slots and converts times to the requester's offset. It checks each slot against the busy ranges before it proposes it, but it can still miss an overlap. Review the proposed slot before you approve the booking.
- The agent uses a fixed UTC offset, not a time zone, so it doesn't account for a daylight saving time change between today and the meeting day. Today's date is in UTC, so near midnight a relative day such as "tomorrow" can resolve to a different day than the requester's local date.
- `listEvents` reads one page of events, up to 250 for the day. If a day has more events, or Google returns a shorter page with a `nextPageToken`, a busy event can be missing from the list. The approval step lets you check the slot before the event is created.
- The sample checks one colleague's calendar. It doesn't find a common slot across several calendars.
- The agent doesn't handle recurring meetings, rescheduling, or cancellation.

The model chooses which calendar to read and write. Authenticate requesters and restrict the calendars that the agent can access before you deploy it.
