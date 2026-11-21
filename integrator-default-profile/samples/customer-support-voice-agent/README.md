# Customer Support Voice Agent

## Description

A customer support assistant for an online store that customers can talk to by voice or chat with over HTTP. The agent checks order status, explains the return policy, and creates support tickets, keeping its replies short so they sound natural when spoken.

### What it does

- Looks up an order by its ID and reports its status and estimated delivery (sample orders: `ORD-1001`, `ORD-1002`, `ORD-1003`).
- Explains the store's return policy.
- Creates a support ticket for an issue the customer reports.
- Reaches the same agent through two entry points:
  - **Chat service** (`/customer-support-agent/chat`): an HTTP chat endpoint on port 9090.
  - **Voice service**: a `CloudVoiceListener` on port 8080 that receives transcribed speech from the voice agent and returns the agent's reply.

## Prerequisites

Before running this integration, you need:

### OpenAI Setup

1. Sign in to the [OpenAI platform](https://platform.openai.com/).
2. Go to **API keys** and click **Create new secret key**.
3. Copy the key.

### Voice Setup

To talk to the agent by voice, you need a **WSO2 Cloud** organization where you can deploy AI agents and enable voice agents.

## Configuration

The following configurations are required for the integration:

### OpenAI Configuration
- `apiKey`: The OpenAI API key obtained from the OpenAI setup.

To run the integration locally, provide the configuration in a `Config.toml` file in the project root:

```toml
[openAIConfig]
apiKey = "<OPENAI_API_KEY>"
```

Then send a chat request to the chat endpoint:

```bash
curl -X POST http://localhost:9090/customer-support-agent/chat \
  -H "Content-Type: application/json" \
  -d '{"sessionId": "session-1", "message": "Where is my order ORD-1001?"}'
```

## Deploying on **WSO2 Cloud**

1. Sign in to your WSO2 Cloud account.
2. Create a new Integration and follow instructions in [WSO2 Cloud Documentation](https://wso2.com/devant/docs/references/import-a-repository/) to import this repository.
3. Select the **Technology** as `WSO2 Integrator: BI`.
4. Choose the **Integration** Type as `AI Agent` and click **Create**.
5. Once the build is successful, click **Configure to Continue** and set the required configurations.
6. On the integration's **Overview** page, click **Enable voice agent** to create a voice agent that connects to the voice listener.
7. Once tested, you may promote the integration to production. Make sure to set the relevant configurations in the production environment as well.
