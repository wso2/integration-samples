# Transactional Outbox with CDC and RabbitMQ

Demonstrates the Transactional Outbox pattern: user registration writes to both the `users` table and an `outbox` table in a single database transaction. A PostgreSQL CDC listener tails the outbox and publishes each new entry to RabbitMQ, guaranteeing the event is never lost even if the broker is temporarily unavailable.

## How it works

- `POST /users/register` writes the user and an outbox entry atomically.
- The PostgreSQL CDC listener detects the insert and calls `onCreate`.
- `onCreate` publishes the event to RabbitMQ exchange `user-events`.

## Prerequisites

- PostgreSQL with **logical replication** enabled (`wal_level = logical`) and the `accounts` database:

```sql
CREATE DATABASE accounts;
\c accounts
CREATE TABLE users (id TEXT PRIMARY KEY, email TEXT, name TEXT);
CREATE TABLE outbox (
    id             TEXT PRIMARY KEY,
    aggregate_type TEXT,
    event_type     TEXT,
    payload        JSONB
);
```

- RabbitMQ (default: `localhost:5672`) with a `direct` exchange named `user-events`:

```bash
rabbitmqadmin declare exchange name=user-events type=direct
```

## Run locally

```bash
bal run
curl -X POST http://localhost:8090/users/register \
  -H 'Content-Type: application/json' \
  -d '{"id":"u1","email":"alice@example.com","name":"Alice"}'
```

## Deploy on WSO2 Cloud

Deploy this integration on **WSO2 Cloud** as an **Event Integration**.

[![Deploy on WSO2 Cloud](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/outbox_cdc_rabbitmq)
