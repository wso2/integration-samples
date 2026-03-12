# GitHub PR Merged Slack Notification Integration

## Description

This integration automatically sends formatted Slack notifications whenever a Pull Request is merged in your GitHub repositories. It provides rich details about the merged PR including code statistics, cycle time metrics, and customizable routing to different Slack channels based on repository or branch.

### What It Does

- Listens for GitHub webhook events when Pull Requests are closed
- Filters merged PRs based on configurable criteria (base branch, labels, author)
- Calculates PR cycle time (time from creation to merge)
- Sends formatted Slack notifications with:
  - Repository and PR information
  - Author details
  - Target branch
  - PR description (optional)
  - List of reviewers (optional)
  - Code change statistics (files changed, additions, deletions)
  - Cycle time metrics in human-readable format
- Routes notifications to different Slack channels based on repository or branch

## Prerequisites

Before running this integration, you need:

### GitHub Setup

1. A GitHub repository with administrative access
2. Webhook configuration:
   - A publicly accessible URL for the webhook endpoint (for production)
   - For local testing, you can use tools like ngrok to expose your local server
3. Repository permissions to receive webhook events

### Slack Setup

1. A Slack workspace with permission to create apps
2. A Slack app with the following:
   - Bot User OAuth Token (starts with `xoxb-`)
   - Required bot token scopes:
     - `chat:write` - To post messages to channels
     - `chat:write.public` - To post to public channels without joining
3. The bot must be added to the target Slack channel(s)

[Learn how to create a Slack app and get your Bot Token](https://api.slack.com/start/quickstart)

## Configuration

The following configurations are required in your `Config.toml` file:

### Slack Configuration

- `slackToken` - Your Slack Bot User OAuth Token (e.g., `xoxb-...`)
- `slackChannelId` - Default Slack channel ID to post notifications (e.g., `C0AKY8K8DT3`)

### GitHub Webhook Configuration

- `webhookPort` - Port number for the webhook listener (default: `8090`)
- `githubCallback` - Public URL for GitHub webhooks (leave empty for local testing)
- `githubRepos` - Array of repositories to monitor in `org/repo` format (e.g., `["TharaniDJ/devant"]`)

### Optional Filters

Customize which PRs trigger notifications:

- `filterBaseBranches` - Only notify for PRs targeting specific branches (e.g., `["main", "develop"]`)
- `filterLabels` - Only notify for PRs with specific labels (empty array allows all labels)
- `filterAuthor` - Only notify for PRs from a specific GitHub username (empty string allows all authors)

### Message Customization

Control what information appears in Slack notifications:

- `includePrDescription` - Include PR description in the message (default: `true`)
- `includeReviewers` - Include list of requested reviewers (default: `true`)
- `includeDiffStats` - Include code change statistics (default: `true`)
- `includeCycleTime` - Include PR cycle time metrics (default: `true`)

### Channel Routing

Route notifications to different channels based on repository or branch:

- `channelRouting` - Array of routing rules in format:
  - `"org/repo:CHANNEL_ID"` - Route all PRs from a repo to a specific channel
  - `"org/repo/branch:CHANNEL_ID"` - Route PRs to a specific branch to a channel

Example:
```toml
channelRouting = [
    "TharaniDJ/devant/main:C0AKY8K8DT3",      # Main branch PRs → #releases
    "TharaniDJ/devant/develop:C0AKY8UU74Z"    # Develop branch PRs → #dev-updates
]
```

## Deploying on **Devant**

1. Sign in to your Devant account.
2. Create a new Integration and follow instructions in [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `Event-Driven` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables:
   - `slackToken` - Your Slack Bot OAuth Token
   - `slackChannelId` - Default Slack channel ID
   - `githubRepos` - Array of repositories to monitor
   - Configure optional filters and message customization as needed
6. Click **Deploy** to deploy the integration.
7. Configure GitHub webhook:
   - Go to your GitHub repository → Settings → Webhooks → Add webhook
   - Set Payload URL to your deployed integration endpoint
   - Content type: `application/json`
   - Select "Let me select individual events" → Check "Pull requests"
   - Click "Add webhook"
8. Test by merging a PR in your configured repository.
9. Once tested, you may promote the integration to production. Make sure to:
   - Set the relevant environment variables in the production environment
   - Update the GitHub webhook URL to point to the production endpoint

## Example Slack Notification

When a PR is merged, you'll receive a notification like this:

```
🎉 *Pull Request Merged Successfully!*

*Repository:* TharaniDJ/devant
*Pull Request:* #42 - Add user authentication feature
*Author:* @johndoe
*Target Branch:* `main`

─────────────────────────

*Description:*
Implemented OAuth2 authentication with JWT tokens for secure user login...

*Reviewers:* @janedoe, @bobsmith

*Code Changes:*
   • Files changed: 8
   • Additions: +342 lines
   • Deletions: -89 lines

*Cycle Time:* 2.3 day(s)

✅ *Status:* Merged and ready to deploy!
```

## Troubleshooting

- **Notifications not appearing**: Verify the Slack bot is added to the target channel and has `chat:write` permissions
- **Webhook not triggering**: Check that the GitHub webhook is configured with the correct URL and "Pull requests" event is selected
- **Filtering not working**: Double-check your filter configurations in `Config.toml` match your repository/branch names exactly
