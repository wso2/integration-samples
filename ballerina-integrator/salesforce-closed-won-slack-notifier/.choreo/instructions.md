## What It Does

- Listens to real-time Salesforce Opportunity change events
- Detects when opportunities are marked as "Closed Won"
- Filters opportunities based on configurable criteria (deal size, type, owner)
- Routes notifications to different Slack channels based on deal size tiers
- Sends formatted Slack notifications with deal details and owner mentions
- Includes retry logic for reliable message delivery

<details>

<summary>Salesforce Setup Guide</summary>

1. A Salesforce account with API access and Change Data Capture enabled
2. OAuth2 credentials:
  - Client ID
  - Client Secret
  - Refresh Token
  - Refresh URL
  - Base URL (your Salesforce instance URL)
3. Change Data Capture must be enabled for the **Opportunity** object in Salesforce Setup

This integration uses refresh token flow for auth. [Learn how to set up Salesforce OAuth](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5).

</details>

<details>
  
<summary>Slack Setup Guide</summary>

1. A Slack app with a Bot Token
2. The bot must be invited to all channels it will post to
3. Scopes Required:
  - `chat:write` - Send messages
  - `chat:write.public` - Send messages to channels without joining

[Learn how to create a Slack app](https://api.slack.com/start/quickstart).

</details>

<details> 

<summary>Additional Configurations</summary>

### Business Rules

1. **`minDealAmount`** (decimal)
   - Minimum opportunity amount to trigger notifications
   - Opportunities below this threshold are ignored

### Filtering Options

2. **`allowedTypes`** (string array)
   - Filter opportunities by Type field
   - Example: `["New Customer", "Existing Customer - Upgrade"]`
   - Leave empty `[]` to allow all types

3. **`allowedOwners`** (string array)
   - Filter opportunities by Owner Name
   - Example: `["<OWNER_NAME_1>", "<OWNER_NAME_2>"]`
   - Leave empty `[]` to allow all owners

### Slack Customization

4. **`ownerSlackMapping`** (string array)
   - Map Salesforce owner names to Slack user IDs for mentions
   - Format: `"Salesforce Name:SlackUserID"`
   - Get Slack user IDs: Click user profile → More → Copy member ID

5. **`dealSizeTierChannels`** (string array)
   - Route notifications to different channels based on deal size
   - Format: `"threshold:channelId"`
   - Deals are sent to the highest matching tier
   - Falls back to `slackChannel` if no tier matches

</details>

<details>

<summary>Troubleshooting</summary>

#### 1. No Notifications Received

**Possible Causes:**
- Salesforce Platform Events not enabled
- Opportunity doesn't meet filter criteria
- Slack channel configuration incorrect

**Solutions:**
- Verify Platform Events are enabled in Salesforce Setup
- Check logs to see if events are being received
- Verify `minDealAmount` threshold is not too high
- Ensure opportunity type matches `allowedTypes`
- Confirm owner name matches `allowedOwners` (if configured)
- Verify Slack channel IDs are correct (not channel names)

#### 2. Salesforce Connection Errors

**Error:** "Authentication failed" or "Invalid refresh token"

**Solutions:**
- Verify all Salesforce credentials are correct
- Ensure refresh token hasn't expired - regenerate if needed
- Check that `baseUrl` matches your Salesforce instance
- Confirm OAuth app has necessary permissions
- Verify `refreshUrl` is correct for your instance

#### 3. Slack Message Delivery Failures

**Error:** "Slack client failed"

**Solutions:**
- Verify `slackToken` is valid and starts with `xoxb-`
- Check that Slack app has required scopes (`chat:write`, `chat:write.public`)
- Verify channel IDs exist and bot has access to channels
- Check Slack app is installed in your workspace

#### 4. Owner Mentions Not Working

**Problem:** Owner names appear as plain text instead of @mentions

**Solutions:**
- Verify `ownerSlackMapping` format: `["Salesforce Name:SlackUserID"]`
- Get correct Slack user IDs: User profile → More → Copy member ID
- Ensure Salesforce owner name exactly matches mapping key
- Check for extra spaces or special characters in mapping

#### 5. Wrong Channel Routing

**Problem:** Messages go to default channel instead of tier-specific channels

**Solutions:**
- Verify `dealSizeTierChannels` format: `["threshold:channelID"]`
- Ensure thresholds are numeric values (e.g., `["10000:C123456"]`)
- Check that deal amount exceeds configured thresholds
- Verify channel IDs are correct
- Confirm bot has access to all configured channels

</details>
