# Gmail Label Agent

## Description

An AI agent that keeps a Gmail inbox organized. Every five minutes, it checks the inbox for new emails and labels each one. It reuses the best matching existing label, or creates a new label under `AI/` when none fits. It also moves promotional emails out of the inbox. This sample shows how to build an AI agent in WSO2 Integrator that runs on a schedule and takes actions in a business system, not one that answers chat messages.

## Prerequisites

- A Gmail account, and a Google Cloud project with the Gmail API enabled. Follow the [setup guide of the Ballerina Gmail connector](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#setup-guide) to create an OAuth client and get a refresh token. When you authorize the Gmail APIs in the OAuth 2.0 Playground, include the `https://www.googleapis.com/auth/gmail.modify` scope, because the agent creates labels and changes the labels on emails.
- An OpenAI API key with access to the `gpt-6-luna` model.

If your OAuth consent screen is in the **Testing** publishing status, Google expires the refresh token after seven days. Get a new token when that happens, or publish the app.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
openAiApiKey = "<OPENAI_API_KEY>"
gmailClientId = "<GMAIL_CLIENT_ID>"
gmailClientSecret = "<GMAIL_CLIENT_SECRET>"
gmailRefreshToken = "<GMAIL_REFRESH_TOKEN>"
```

## Usage Instructions

1. Run the integration. It only labels emails that arrive after it starts, and checks the inbox every five minutes. While the inbox has no new emails, the log shows `No new emails`.
2. Send an email to the Gmail account. To see the agent take an email out of the inbox, forward a marketing newsletter or another promotional email to it.
3. Wait for the next check. The log shows `Email labeled` with the message ID and a one-sentence summary from the agent, such as:

   ```
   Applied AI/Newsletters and removed the email from the inbox because it is promotional.
   ```

4. Open Gmail. The email has the label. A promotional email is no longer in the inbox, but you can still find it under its label or in **All Mail**.

## How It Works

- A task listener runs the poll every five minutes. Each poll lists the inbox emails that arrived between the start of the previous poll and the start of this one (`in:inbox after:<time> before:<time>`), up to 100 emails. If more arrived, it labels the newest 100 and logs a warning that the older ones were skipped. If a poll is still running when the next one is due, the next one is skipped, and the following poll covers its emails.
- Each poll reads the mailbox's user labels once. For each email, the integration fetches only the sender and subject headers, not the body, and gives the agent the message ID, sender, subject, snippet and the list of user labels with their IDs.
- The agent uses OpenAI `gpt-6-luna` through the Responses API. It has no memory, so each email is labeled on its own.
- It implements three agent tools:
  - **applyLabel**: Applies a label to an email
  - **createLabel**: Creates a label. It rejects names that do not start with `AI/`, so the agent's labels stay in one place. The new label is added to the poll's label list, so later emails in the same poll can reuse it.
  - **removeFromInbox**: Removes the `INBOX` label from an email, which archives it without deleting it. The agent uses it only for promotional emails.
- The agent's instructions tell it to pick only user labels, and never to apply system labels such as `INBOX`, `UNREAD` or `CATEGORY_*`.
- If a poll cannot list the inbox or read the labels, the next poll covers the same time window again. If the agent fails on an email, the integration logs the error and skips that email.
- The integration keeps the time of the last poll in memory, so emails that arrive while it is stopped are not labeled.
