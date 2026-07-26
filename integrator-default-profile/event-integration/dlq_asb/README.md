# DLQ + Retry with Azure Service Bus

Demonstrates dead-letter queue (DLQ) handling with Azure Service Bus. Messages follow three paths based on the `recipient` field: successful delivery (`complete`), transient failure (`abandon` — requeued until `maxDeliveryCount`, then auto-DLQ), or permanent failure (`deadLetter` — immediate DLQ with a reason).

## How it works

| `recipient` value | Action | Result |
|---|---|---|
| Any valid string | `complete()` | Message acknowledged |
| `"down"` | `abandon()` | Requeued; auto-DLQ after 5 attempts |
| `"invalid"` | `deadLetter(...)` | Immediately moved to DLQ |

## Prerequisites

- Azure Service Bus connection string (real or emulator). Set it in `Config.toml`:

```toml
connectionString = "Endpoint=sb://..."
queueName = "notifications"
```

## Run locally

```bash
bal run
# Delivered successfully
curl -X POST http://localhost:8090/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{"channel":"sms","recipient":"alice","message":"Hello"}'
# Trigger retry then DLQ
curl -X POST http://localhost:8090/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{"channel":"push","recipient":"down","message":"Hello"}'
# Immediate dead-letter
curl -X POST http://localhost:8090/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{"channel":"sms","recipient":"invalid","message":"Hello"}'
```

## Deploy on Devant

Deploy this integration on **Devant** as an **Event Integration**.

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/dlq_asb)
