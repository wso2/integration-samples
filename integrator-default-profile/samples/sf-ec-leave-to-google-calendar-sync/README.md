# Sync SAP SuccessFactors Employee Leave to Google Calendar

## Description

A scheduled WSO2 Integrator automation that reads approved leave starting today or tomorrow from SAP SuccessFactors Employee Central and creates a matching "Out of office" event on Google Calendar. Each event carries the SuccessFactors leave ID in its description, so it can always be traced back to the record that created it.

This is the sample project for the how-to guide [Sync SAP SuccessFactors Employee Leave to Google Calendar](https://wso2.com/integration-platform/docs/guides/howtoguides/sf-ec-leave-to-google-calendar-sync).

## What It Does

- Calls the SAP SuccessFactors EC Time Off connector's **List Employee Times** operation with an OData filter for `APPROVED` leave whose start date falls between today and tomorrow
- Converts the SuccessFactors OData date values (`/Date(1790208000000)/`) into plain `YYYY-MM-DD` dates
- Creates one all-day Google Calendar event per leave on the `primary` calendar, titled `[Out of office] <userId>`
- Logs the created event ID and leave ID for each event, then a completion message

## Prerequisites

### SAP SuccessFactors Setup

An SAP SuccessFactors Employee Central tenant with an OAuth 2.0 SAML Bearer Assertion client registered in **Admin Center > Manage OAuth2 Client Applications**. You need:

- API key (the registered client's key)
- Company ID
- API username
- Private key and X.509 certificate of the registered client
- Token URL (for example, `https://api12preview.sapsf.eu/oauth/token`)
- API hostname (for example, `api12preview.sapsf.eu`)

Follow the [SAP SuccessFactors EC Time Off connector setup guide](https://wso2.com/integration-platform/docs/connectors/catalog/hrms/sap.successfactors.ectimeoff/setup-guide) for the exact steps.

### Google Calendar Setup

A Google Cloud project with the Google Calendar API enabled and an OAuth 2.0 client. You need:

- Client ID
- Client Secret
- Refresh Token
- Refresh URL (`https://oauth2.googleapis.com/token`)

Follow the [Google Calendar connector setup guide](https://wso2.com/integration-platform/docs/connectors/catalog/productivity-collaboration/googleapis.calendar/setup-guide) for the exact steps.

## Configuration

Create a `Config.toml` file in the project root with the following values.

### SAP SuccessFactors Credentials

- `apiKey` - OAuth2 client API key
- `companyId` - SuccessFactors company ID
- `userName` - API username
- `privateKey` - Private key of the OAuth2 client (PEM body)
- `certificate` - X.509 certificate of the OAuth2 client (PEM body)
- `tokenUrl` - OAuth2 token endpoint
- `hostName` - SuccessFactors API hostname

### Google Calendar Credentials

- `clientId` - Google OAuth2 client ID
- `clientSecret` - Google OAuth2 client secret
- `refreshToken` - Google OAuth2 refresh token
- `refreshUrl` - Google OAuth2 token endpoint

```toml
apiKey = "<SF_API_KEY>"
companyId = "<SF_COMPANY_ID>"
userName = "<SF_API_USERNAME>"
privateKey = "<SF_PRIVATE_KEY>"
certificate = "<SF_CERTIFICATE>"
tokenUrl = "https://<SF_API_HOST>/oauth/token"
hostName = "<SF_API_HOST>"
clientId = "<GOOGLE_CLIENT_ID>"
clientSecret = "<GOOGLE_CLIENT_SECRET>"
refreshToken = "<GOOGLE_REFRESH_TOKEN>"
refreshUrl = "https://oauth2.googleapis.com/token"
```

## Usage Instructions

1. Open the project in WSO2 Integrator and supply the values above under **Configurations**, or create `Config.toml` as shown.
2. Make sure at least one approved leave in SuccessFactors starts today or tomorrow.
3. Select **Run** on the integration overview, or run `bal run` from the project root.

### Deploy on WSO2 Cloud

1. Deploy this integration on **WSO2 Cloud** as an **Automation**.
2. Configure the SAP SuccessFactors and Google Calendar credentials before running the **Automation**.
3. Schedule it to run once a day.

## How It Works

1. `connections.bal` creates the SAP SuccessFactors EC Time Off client (OAuth2 SAML bearer auth) and the Google Calendar client (OAuth2 refresh token auth), both bound to configurables.
2. `automation.bal` lists approved `EmployeeTime` records starting between today and tomorrow, ordered by start date.
3. For each record it converts the OData start and end dates with `odataDateToIsoDate` in `functions.bal` and creates an all-day Google Calendar event.
4. Every created event is logged with its calendar event ID and SuccessFactors leave ID, followed by a completion log.

## Example Log Output

```
time=2026-09-28T10:30:02.117+05:30 level=INFO module=wso2/sf_ec_leave_to_google_calendar_sync message="Created Google Calendar leave event" eventId="7k2m9q1r8p3s5t6u" leaveId="EMPTIME-2026-0001"
time=2026-09-28T10:30:02.118+05:30 level=INFO module=wso2/sf_ec_leave_to_google_calendar_sync message="Leave synchronization complete"
```

## References

- [How-to guide: Sync SAP SuccessFactors Employee Leave to Google Calendar](https://wso2.com/integration-platform/docs/guides/howtoguides/sf-ec-leave-to-google-calendar-sync)
- [SAP SuccessFactors EC Time Off connector](https://wso2.com/integration-platform/docs/connectors/catalog/hrms/sap.successfactors.ectimeoff/overview)
- [Google Calendar connector](https://wso2.com/integration-platform/docs/connectors/catalog/productivity-collaboration/googleapis.calendar/overview)
