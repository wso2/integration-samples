# Customer Support Voice Agent

## Description

A customer support assistant for an online store that customers can talk to by voice or text. This sample demonstrates how to build an AI agent in WSO2 Integrator and expose it through both a chat endpoint and a cloud voice listener. The agent helps customers check their order status, understand the return policy, and raise support tickets.

## Prerequisites

- An OpenAI API key.
- To talk to the agent by voice, a **WSO2 Cloud** organization where you can deploy AI agents and enable voice agents.

## Configuration

Provide the OpenAI API key through a `Config.toml` file in the project root:

```toml
apiKey = "<OPENAI_API_KEY>"
```

## Usage Instructions

1. Run the integration to start the chat service and the voice listener.
2. Send a chat request to the chat endpoint:

   ```bash
   curl -X POST http://localhost:9090/customer-support-agent/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "session-1", "message": "Where is my order ORD-1001?"}'
   ```

3. To talk to the agent by voice:
   1. Deploy this integration as an AI agent in **WSO2 Cloud**.
   2. On the agent's overview page, select **Enable Voice Agent**. This creates a voice agent that connects to the integration's voice listener.

## How It Works

- The agent uses OpenAI's `gpt-4o-mini` model with an in-memory short-term memory that keeps the last 20 messages for each session.
- It implements three agent tools:
  - **getOrderStatus**: Looks up an order by its ID (sample orders: `ORD-1001`, `ORD-1002`, `ORD-1003`)
  - **getReturnPolicy**: Returns the store's return policy
  - **createSupportTicket**: Creates a support ticket for a reported issue
- Requests reach the same agent from two entry points:
  - **Chat service** (`/customer-support-agent/chat`): an HTTP chat endpoint on the default listener
  - **Voice service**: a `CloudVoiceListener` on port 8080 that receives transcribed speech from the voice agent and returns the agent's reply
- The agent keeps every reply short and conversational, with no Markdown, lists, or code, so replies read naturally when spoken aloud.
