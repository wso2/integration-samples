## What it does

- Answers customers of an online store by voice or chat.
- Checks the status of an order, explains the return policy, and creates a support ticket for a reported issue.
- Keeps every reply to one or two short sentences, so it sounds natural when spoken aloud.

<details>

<summary>OpenAI Setup Guide</summary>

1. Sign in to the [OpenAI platform](https://platform.openai.com/).
2. Go to **API keys** and click **Create new secret key**.
3. Copy the key. This should be the `apiKey` configuration under `openAIConfig`.

</details>

<details>

<summary>Voice Setup Guide</summary>

The following should be done after deploying the integration.

1. Go to the integration's **Overview** page.
2. Click **Enable voice agent**. This creates a voice agent that connects to the integration's voice listener on port 8080.
3. Use the voice agent to talk to the customer support agent, for example by asking "Where is my order ORD-1001?".

</details>
