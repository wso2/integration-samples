## What It Does
- Listens for GitHub webhook events when Pull Requests are closed
- Filters merged PRs based on configurable criteria (base branch, labels, author)
- Calculates PR cycle time (time from creation to merge)
- Sends formatted Slack notifications with PR details, code statistics, and metrics
- Routes notifications to different Slack channels based on repository or branch

<details>
<summary>Slack Setup Guide</summary>

1. Create a Slack App:
   - Go to [https://api.slack.com/apps](https://api.slack.com/apps)
   - Click "Create New App" → "From scratch"
   - Name your app and select your workspace

2. Configure Bot Token Scopes:
   - Navigate to "OAuth & Permissions" in the left sidebar
   - Under "Scopes" → "Bot Token Scopes", add:
     - `chat:write` - To post messages to channels
     - `chat:write.public` - To post to public channels without joining

3. Install App to Workspace:
   - Click "Install to Workspace" at the top of the OAuth & Permissions page
   - Authorize the app

4. Get Your Bot Token:
   - After installation, copy the "Bot User OAuth Token" (starts with `xoxb-`)
   - This is your `slackToken`

5. Get Channel ID:
   - Open Slack, right-click on the channel name
   - Select "View channel details"
   - Scroll down to find the Channel ID (e.g., `C0AKY8K8DT3`)
   - This is your `slackChannelId`

6. Add Bot to Channels:
   - In each channel you want to post to, type `/invite @YourBotName`

[Learn more about creating Slack apps](https://api.slack.com/start/quickstart)
</details>

<details>
<summary>GitHub Webhook Setup Guide</summary>

1. Deploy Your Integration:
   - First deploy this integration on Devant to get your webhook endpoint URL

2. Configure GitHub Webhook:
   - Go to your GitHub repository
   - Click "Settings" → "Webhooks" → "Add webhook"
   - Set "Payload URL" to your deployed integration endpoint
   - Set "Content type" to `application/json`
   - Under "Which events would you like to trigger this webhook?":
     - Select "Let me select individual events"
     - Check only "Pull requests"
   - Ensure "Active" is checked
   - Click "Add webhook"

3. Test the Webhook:
   - Merge a Pull Request in your repository
   - Check the "Recent Deliveries" tab in webhook settings to verify delivery

**Note:** For local testing, use tools like [ngrok](https://ngrok.com/) to expose your local server.
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
