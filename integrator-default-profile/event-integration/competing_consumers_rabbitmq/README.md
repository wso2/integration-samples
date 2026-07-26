# Competing Consumers with RabbitMQ

Demonstrates the Competing Consumers pattern: thumbnail resize jobs are published to a shared RabbitMQ queue and distributed among multiple consumer instances. RabbitMQ round-robins messages so no two workers process the same job.

## How it works

- `POST /jobs/resize` enqueues a `ResizeJob` onto `thumbnail-queue`.
- One or more instances of the consumer service compete for jobs.
- Each job takes ~2 seconds (simulated), making the distribution visible in logs.

## Prerequisites

- RabbitMQ (default: `localhost:5672`, user `guest`/`guest`)

## Run locally

```bash
# Start two consumer instances in separate terminals
bal run
bal run -- --http.port=8091

# Enqueue jobs
curl -X POST http://localhost:8090/jobs/resize \
  -H 'Content-Type: application/json' \
  -d '{"imageId":"img-1","sourceUrl":"https://example.com/photo.jpg"}'
```

## Deploy on Devant

Deploy this integration on **Devant** as an **Event Integration**.

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/competing_consumers_rabbitmq)
