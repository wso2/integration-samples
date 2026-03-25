## What It Does
- Listens for GitHub webhook events when Pull Requests are closed
- Filters merged PRs based on configurable criteria (base branch, labels, author)
- Calculates PR cycle time (time from creation to merge)
- Sends formatted Slack notifications with PR details, code statistics, and metrics
- Routes notifications to different Slack channels based on repository or branch

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
<summary>GitHub Setup Guide</summary>

1. A GitHub account with access to the repositories you want to monitor

The following should be done after deploying the integration, and the endpoint URL is available.

1. Set up a webhook on the repository:
   - Go to your GitHub repository **Settings > Webhooks > Add webhook**
   - Set **Payload URL** to your deployed integration endpoint
   - Set **Content type** to `application/json`
   - Optionally set a secret for security (if you do, make sure to add it to the integration configuration as well)
   - Under events select **"Let me select individual events"**
   - Check **Issues**
   - Click **Add webhook**

</details>

<details>
<summary>Additional Configurations</summary>

### Required Configurations

1. `slackToken`
   - Your Slack Bot User OAuth Token (starts with `xoxb-`)
   - Obtained from Slack App "OAuth & Permissions" page

2. `slackChannelId`
   - Default Slack channel ID to post notifications (e.g., `C0AKY8K8DT3`)
   - Found in Slack channel details

3. `githubRepos`
   - Array of GitHub repositories to monitor in `org/repo` format
   - Example: `["TharaniDJ/devant", "myorg/myrepo"]`

### Webhook Configuration

1. `webhookPort`
   - Port number for the webhook listener
   - Default: `8090`

2. `githubCallback`
   - Public URL for GitHub webhooks
   - Leave empty for local testing
   - For production, set to your deployed endpoint URL

### Optional Filters

1. `filterBaseBranches`
   - Only notify for PRs targeting specific branches
   - Example: `["main", "develop"]`
   - Default: `["main"]`

2. `filterLabels`
   - Only notify for PRs with specific labels
   - Example: `["ready-to-merge", "approved"]`
   - Empty array `[]` allows all labels

3. `filterAuthor`
   - Only notify for PRs from a specific GitHub username
   - Example: `"john-doe"`
   - Empty string `""` allows all authors

### Message Customization

1. `includePrDescription`
   - Include PR description in Slack message
   - Default: `true`

2. `includeReviewers`
   - Include list of requested reviewers
   - Default: `true`

3. `includeDiffStats`
   - Include code change statistics (files, additions, deletions)
   - Default: `true`

4. `includeCycleTime`
   - Include PR cycle time metrics
   - Default: `true`

### Channel Routing

1. `channelRouting`
   - Route notifications to different channels based on repository or branch
   - Array of routing rules in format:
     - `"org/repo:CHANNEL_ID"` - Route all PRs from a repo to a specific channel
     - `"org/repo/branch:CHANNEL_ID"` - Route PRs to a specific branch to a channel
   - Example:
     ```
     ["TharaniDJ/devant/main:C0AKY8K8DT3", "TharaniDJ/devant/develop:C0AKY8UU74Z"]
     ```
   - If no match found, uses default `slackChannelId`
</details>
