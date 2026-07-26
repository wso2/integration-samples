# Pub/Sub with Kafka

Demonstrates the Pub/Sub pattern using Apache Kafka. A storefront publishes `PageViewed` events to a Kafka topic, and an independent consumer subscribes to react — in this case updating recommendations — without any coupling to the producer.

## How it works

- `POST /publish/pageview` accepts a `PageViewed` event and publishes it to the configured Kafka topic.
- A Kafka listener subscribes to the same topic with its own consumer group and processes events independently.
- Adding a new consumer (analytics, anomaly monitor) means a new listener with a new group ID — the producer never changes.

## Prerequisites

- Kafka broker (default: `localhost:9092`)

## Run locally

```bash
bal run
curl -X POST http://localhost:8090/publish/pageview \
  -H 'Content-Type: application/json' \
  -d '{"userId":"u1","url":"/pricing","sessionId":"s1"}'
```

## Deploy on Devant

Deploy this integration on **Devant** as an **Event Integration**.

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/pubsub_kafka)
