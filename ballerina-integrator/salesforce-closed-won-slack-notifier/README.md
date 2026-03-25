# Salesforce to Slack Notification Integration

## Description

This integration automatically sends real-time Slack notifications when opportunities are marked as "Closed Won" in Salesforce. It listens to Salesforce platform events and intelligently routes notifications to different Slack channels based on deal size, with support for owner mentions and customizable filtering.

### What It Does

- Listens to Salesforce Opportunity Change Events in real-time and detects opportunities marked "Closed Won".
- Filters opportunities by minimum deal amount, allowed record types (e.g., `New Customer`, `Existing Customer - Upgrade`), and opportunity owners.
- Routes notifications to different Slack channels based on deal size tiers and mentions opportunity owners in Slack using @mentions.
- Includes comprehensive deal information in notifications: deal name and amount, close date, owner (with Slack mention), account name, opportunity type, lead source, competitor information, and description.
- Implements retry logic for reliability.

## Prerequisites

Before running this integration, you need:

### Salesforce Setup

1. A Salesforce account with API access and Platform Events enabled
2. OAuth2 credentials:
   - Client ID
   - Client Secret
   - Refresh Token
   - Refresh URL
   - Base URL (your Salesforce instance URL)
3. Opportunity Change Events must be enabled in your Salesforce org

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

### Slack Setup

1. A Slack workspace with admin access
2. A Slack App with the following:
   - Bot Token (for Slack API)
   - OAuth scopes:
     - `chat:write`
     - `chat:write.public`
3. Slack channel IDs for notification routing
4. Slack user IDs for owner mentions

[Learn how to create a Slack App](https://api.slack.com/start/quickstart).

## Configuration

The following configurations are required to connect to Salesforce and Slack.

### Salesforce Credentials

- `baseUrl` - Your Salesforce instance URL (e.g., `https://your-instance.salesforce.com`)
- `refreshToken` - Your Salesforce OAuth2 refresh token
- `refreshUrl` - Salesforce OAuth2 token endpoint (e.g., `https://your-instance.salesforce.com/services/oauth2/token`)
- `clientId` - Your Salesforce OAuth2 client ID
- `clientSecret` - Your Salesforce OAuth2 client secret

### Slack Credentials

- `slackToken` - Your Slack bot token (starts with `xoxb-`)
- `slackChannel` - Default Slack channel ID

### Business Logic Configuration

- `minDealAmount` - Minimum deal amount to trigger notifications
- `allowedTypes` - Array of opportunity types to include (e.g., `["New Customer", "Existing Customer - Upgrade"]`)
- `allowedOwners` - Array of owner names to filter (leave empty to allow all)

### Owner to Slack Mapping

- `ownerSlackMapping` - Maps Salesforce owner names to Slack user IDs for @mentions
  - Format: `["Salesforce Name:SlackUserID"]`
  - Get Slack user IDs: Click user profile → More → Copy member ID

### Deal Size Tier Channels

- `dealSizeTierChannels` - Routes notifications to specific channels based on deal amount
  - Format: `["threshold:channelID"]`
  - Deals are routed to the highest matching threshold

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Event Integration` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Salesforce and Slack credentials.
6. Configure the business logic settings:
   - Set `minDealAmount` to your desired threshold
   - Configure `allowedRecordTypes` to filter opportunity types
   - Set up `ownerSlackMapping` to enable @mentions
   - Configure `dealSizeTierChannels` for intelligent routing
7. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
