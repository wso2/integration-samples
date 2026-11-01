## What It Does

- Subscribes to Salesforce Change Data Capture events for Lead objects
- Detects when a lead is converted (`IsConverted` is set to `true`)
- Fetches full conversion details from Salesforce — including the associated Account, Contact, Opportunity, and Owner
- Routes the notification to a team-specific Slack channel based on the lead owner's role, falling back to a default channel
- Sends a formatted Slack message with conversion details, lifecycle duration, and a direct link to the opportunity

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access and Change Data Capture enabled
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)
3. Change Data Capture must be enabled for the **Lead** object in Salesforce Setup

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>

<summary>Slack Setup Guide</summary>

1. A Slack app with a Bot Token
2. The bot must be invited to all channels it will post to
3. Scopes Required:
  - `chat:write`
  - `channels:read` (optional, for channel resolution)
  - `users:read.email` (optional, for tagging lead owners by email)

[Learn how to create a Slack app](https://api.slack.com/start/quickstart).

</details>

<details>

<summary>Additional Configurations</summary>

1. `defaultSlackChannel`
    - The fallback Slack channel ID to post notifications to (e.g., `C01234ABCDE`)
2. `teamChannelMappings` *(optional)*
    - A list of team-to-channel mappings for routing notifications based on the lead owner's Salesforce role. Each entry has:
        - `teamName` — a substring to match against the owner's role name (case-insensitive)
        - `channel` — the Slack channel ID to route to for that team
3. `filterLeadSources` *(optional)*
    - A list of lead sources to process (e.g., `["Web", "Phone"]`). If empty, all lead sources are processed.
4. `filterOwnerIds` *(optional)*
    - A list of Salesforce owner IDs to process. If empty, all owners are processed.
5. `messageTemplate` *(optional)*
    - A customizable Slack message template. Supports the following placeholders:
        - `{{lead.name}}` — the lead's name
        - `{{lead.company}}` — the lead's company
        - `{{lead.owner}}` — the lead owner's name (or Slack mention if available)
6. `includeConversionDetails`
    - Set to `true` (default) to append account, contact, opportunity, and lifecycle duration to the message.

</details>
