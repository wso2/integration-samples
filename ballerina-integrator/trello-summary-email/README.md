# Trello Summary Email Integration

## Description

This integration fetches cards from one or more Trello boards and lists, generates a grouped summary, and sends it as an email campaign through Mailchimp on a configurable schedule. It is designed to give teams a regular digest of active Trello cards, highlighting overdue items, card ages, attachment counts, and checklist progress.

### What It Does

- Fetches cards from specified Trello boards and lists
- Applies optional filters by label, member, or due date range
- Groups cards by **List**, **Member**, or **Label**
- Generates a formatted email with:
  - Total card count and overdue card count
  - Per-card details: board, list, due date, labels, members, description, card age, attachments, and checklist progress
- Creates and sends a Mailchimp email campaign to a configured audience list
- Runs automatically on a configurable cron schedule (default: every Monday at 9:00 AM)

## Prerequisites

Before running this integration, you need:

### Trello Setup

1. A Trello account with at least one board containing cards
2. Trello API credentials:
   - **API Key** – available from [https://trello.com/app-key](https://trello.com/app-key)
   - **Token** – generate a token from the same page
3. The **Board IDs** of the boards you want to include
   - Open a board in Trello, click **Share**, and copy the short link. The ID is the alphanumeric part (e.g., `https://trello.com/b/<boardId>/...`)
4. (Optional) The **List IDs** of specific lists to filter - leave empty to include all lists on the board

### Mailchimp Setup

1. A Mailchimp account with a configured audience (list)
2. Mailchimp API credentials:
   - **API Key** – found under **Profile → Extras → API Keys**
   - **Server Prefix** – the prefix shown in your Mailchimp URL (e.g., `us21`)
   - **List ID** – the audience to send the campaign to (found under **Audience → Settings → Audience name and defaults**)
3. A configured sender name and email address for the campaign

## Configuration

Create a `Config.toml` file in the project root with the following values:

```toml
[trelloConfig]
key = "<trello-api-key>"
token = "<trello-token>"
boardIds = ["<board-id-1>", "<board-id-2>"]
listIds = []   # Leave empty to include all lists

[mailchimpConfig]
apiKey = "<mailchimp-api-key>"
serverPrefix = "<server-prefix>"   # e.g., "us21"
listId = "<mailchimp-audience-list-id>"
fromName = "<Sender Name>"
fromAddress = "<sender@example.com>"
subjectPrefix = "Trello Cards Summary"   # Optional, has default
includeDateInSubject = true              # If true, today's date is shown in the subject

[scheduleConfig]
cron = "0 9 * * 1"   # Every Monday at 9:00 AM (default)

[filterConfig]
labels = []                  # Filter by label names; empty means no filter
members = []                 # Filter by member full names; empty means no filter
includeDueDateFilter = false # Set to true to only include cards due within dueDateDaysAhead
dueDateDaysAhead = 7

[summaryConfig]
grouping = "LIST"            # Group by: "LIST", "MEMBER", or "LABEL"
highlightOverdueCards = true
showCardAge = true
staleCardDays = 30           # Cards inactive for this many days are considered stale
showAttachmentCount = true
showChecklistProgress = true
```

### Configuration Reference

#### `trelloConfig`

| Field | Description |
|---|---|
| `key` | Your Trello API key |
| `token` | Your Trello API token |
| `boardIds` | List of Trello board IDs to fetch cards from |
| `listIds` | List of specific list IDs to include; leave empty for all lists |

#### `mailchimpConfig`

| Field | Description |
|---|---|
| `apiKey` | Your Mailchimp API key |
| `serverPrefix` | Mailchimp data center prefix (e.g., `us21`) |
| `listId` | Mailchimp audience list ID to send the campaign to |
| `fromName` | Sender display name for the email campaign |
| `fromAddress` | Sender reply-to email address |
| `subjectPrefix` | Prefix for the email subject line (default: `Trello Cards Summary`) |
| `includeDateInSubject` | If `true` (default), today's date is included in the email subject (e.g., `Trello Cards Summary - 2026-03-12`) |

#### `scheduleConfig`

| Field | Description |
|---|---|
| `cron` | Cron expression for the schedule (default: `0 9 * * 1` — Mondays at 9 AM) |

#### `filterConfig`

| Field | Description |
|---|---|
| `labels` | Only include cards matching these label names; empty means all labels |
| `members` | Only include cards assigned to these members (by full name); empty means all members |
| `includeDueDateFilter` | If `true`, only include cards due within the next `dueDateDaysAhead` days |
| `dueDateDaysAhead` | Number of days ahead to use for the due date filter (default: `7`) |

#### `summaryConfig`

| Field | Description |
|---|---|
| `grouping` | How to group cards in the email: `LIST`, `MEMBER`, or `LABEL` |
| `highlightOverdueCards` | If `true`, overdue cards are flagged in the email |
| `showCardAge` | If `true`, each card shows the number of days since last activity |
| `staleCardDays` | Cards with no activity for this many days are considered stale (default: `30`) |
| `showAttachmentCount` | If `true`, shows the attachment count on each card |
| `showChecklistProgress` | If `true`, shows checklist completion progress on each card |

## Deploying on Devant

1. Sign in to your Devant account.
2. Create a new Integration and follow the instructions in the [Devant Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** type as `Automation` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set up the required environment variables for Trello and Mailchimp credentials.
6. Click **Schedule** to schedule the automation.
7. In the **BY INTERVAL** tab, configure the desired schedule (e.g., weekly on Monday mornings).
8. Click **Update**.
9. Once tested, you may promote the integration to production. Make sure to set the relevant environment variables in the production environment as well.
