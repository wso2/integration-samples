## What It Does

- Fetches cards from specified Trello boards and lists
- Applies optional filters by label, member, or due date range
- Groups cards by **List**, **Member**, or **Label**
- Generates a formatted email summarising all cards, including overdue status, card age, attachments, and checklist progress
- Creates and sends a Mailchimp email campaign to a configured audience list when triggered by Devant automation

<details>

<summary>Trello Setup Guide</summary>

1. A Trello account with at least one board containing cards
2. Trello API credentials:
  - API Key - available from [https://trello.com/app-key](https://trello.com/app-key)
  - Token - generate a token from the same page
3. The **Board IDs** of the boards to include
  - Open a board in Trello, click **Share**, and copy the short link. The ID is the alphanumeric segment: `https://trello.com/b/<boardId>/...`
4. (Optional) **List IDs** to filter specific lists - leave empty to include all lists on the board

</details>

<details>

<summary>Mailchimp Setup Guide</summary>

1. A Mailchimp account with a configured audience (list)
2. Mailchimp API credentials:
  - API Key - found under **Profile → Extras → API Keys**
  - Server Prefix - the prefix shown in your Mailchimp URL (e.g., `us21`)
  - List ID - found under **Audience → Settings → Audience name and defaults**
3. A configured sender name and reply-to email address

</details>

<details>

<summary>Additional Configurations</summary>

1. `filterConfig.labels`
  - Filter cards by label name. Leave empty to include all labels.
3. `filterConfig.members`
  - Filter cards by member full name. Leave empty to include all members.
4. `filterConfig.includeDueDateFilter`
  - Set to `true` to only include cards due within the next `dueDateDaysAhead` days.
5. `mailchimpConfig.includeDateInSubject`
  - If `true` (default), today's date is included in the email subject (e.g., `Trello Cards Summary - 2026-03-12`).
6. `summaryConfig.grouping`
  - How to group cards in the email. Possible values:
    - `LIST` (default)
    - `MEMBER`
    - `LABEL`
7. `summaryConfig.staleCardDays`
  - Cards with no activity for this many days are considered stale (default: `30`).

</details>
