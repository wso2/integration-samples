## What it does

- Answers customers of a sample online store by voice or chat.
- Looks up the status of the sample orders `ORD-1001`, `ORD-1002` and `ORD-1003`, which are hard-coded in the integration.
- Explains the return policy, and returns a support ticket ID for a reported issue. The ticket isn't stored anywhere.
- Keeps every reply to one or two short sentences, so it sounds natural when spoken aloud.

<details>

<summary>OpenAI Setup Guide</summary>

1. Sign in to the [OpenAI platform](https://platform.openai.com/).
2. Go to **API keys** and click **Create new secret key**.
3. Copy the key. This should be the `apiKey` configuration under `openAIConfig`.

</details>

<details>

<summary>Voice Setup Guide</summary>

Voice agents must be included in your organization's plan. The following should be done after deploying the integration.

1. Go to the integration's **Overview** page and click **Enable voice agent**. The button is enabled once the integration is deployed, because the voice agent connects to its WebSocket endpoint on port 8080.
2. Complete the voice agent wizard. The voice agent is created only when you finish it:
    - **Configure agent**: this integration is selected as the agent the voice agent talks to.
    - **Configure LiveKit**: enter the LiveKit server credentials that host the voice sessions.
    - **Configure speech to text**: choose the provider and model that transcribe the caller's speech.
    - **Configure text to speech**: choose the provider, model and voice for the spoken replies.
    - **Tune and deploy**: adjust timing and turn detection, then deploy the voice agent.
3. Talk to the voice agent, for example by asking "Where is my order ORD-1001?".

</details>
