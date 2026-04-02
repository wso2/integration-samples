# Salesforce Lead Conversion Notification to Slack

## Description

This integration listens for Salesforce Lead change events in real time and automatically sends a Slack notification whenever a lead is converted. It fetches full conversion details from Salesforce — including the associated account, contact, and opportunity — and posts a formatted message to the appropriate Slack channel, optionally tagging the lead owner.

### What It Does

- Subscribes to Salesforce Change Data Capture events for Lead objects
- Detects when a lead's `IsConverted` flag is set to `true`
- Queries the full lead details including:
  - ID
  - Name
  - Company
  - Lead Source
  - Owner
  - Converted Account
  - Converted Contact
  - Converted Opportunity
  - Created Date and Converted Date
- Fetches related Salesforce records (Account, Contact, Opportunity, Owner)
- Calculates the lead lifecycle duration in days
- Routes the notification to a team-specific Slack channel based on the owner's role (falls back to a default channel)
- Sends a formatted Slack message with conversion details and a direct link to the opportunity
- Supports optional filtering by lead source or owner ID

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access and Change Data Capture enabled
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
3. Change Data Capture must be enabled for the **Lead** object in Salesforce

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Slack Setup

1. A Slack app with a Bot Token
2. The bot must be invited to all channels it will post to
3. Scopes Required:
   - `chat:write`
   - `users:read.email` (optional, for tagging lead owners by Slack mention)

[Learn how to create a Slack app](https://api.slack.com/start/quickstart).

## Configuration

The following configurations are required to connect to Salesforce and Slack.

### Salesforce Credentials

- `baseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)
- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret
- `refreshToken` - Your Salesforce OAuth2 refresh token
- `refreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://your-instance.salesforce.com/services/oauth2/token`)

### Slack Credentials

- `token` - Your Slack Bot OAuth token
- `defaultChannel` - The fallback Slack channel ID (e.g., `C01234ABCDE`) or channel name (e.g., `#general`) to post notifications to

### Notification Configuration (`notificationConfig`)

- `teamChannelMappings` *(optional)* - A list of team-to-channel mappings for routing notifications based on the lead owner's Salesforce role. Each entry has:
  - `teamName` - A substring to match against the owner's role name (case-insensitive)
  - `channelId` - The Slack channel ID (e.g., `C01234ABCDE`) or channel name (e.g., `#general`) to route to for that team
- `filterLeadSources` *(optional)* - A list of lead sources to process (e.g., `["Web", "Phone"]`). If empty, all lead sources are processed.
- `filterOwnerIds` *(optional)* - A list of Salesforce owner IDs to process. If empty, all owners are processed.
- `messageTemplate` *(optional)* - A customizable message template. Supports the following placeholders:
  - `{{lead.name}}` — the lead's name
  - `{{lead.company}}` — the lead's company
  - `{{lead.owner}}` — the lead owner's name (or Slack mention if available)
- `includeConversionDetails` *(optional)* - Set to `true` (default) to append account, contact, opportunity, and lifecycle duration to the message.

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Event-driven` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Slack credentials.
6. Click **Deploy** to deploy the integration.
7. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
