# CQRS Read-Model Projection with Kafka

Demonstrates the CQRS pattern: match result events flow through Kafka, a projector consumer maintains a denormalized PostgreSQL leaderboard, and reads hit the read model directly — no expensive aggregation on every request.

## How it works

- `POST /matches/add` publishes a `MatchResult` event to the Kafka topic.
- The Kafka consumer (`leaderboard-projector`) upserts each result into the `leaderboard` table.
- `GET /leaderboard/top` queries the pre-computed table.

## Prerequisites

- Kafka broker (default: `localhost:9092`)
- PostgreSQL with the `leaderboard` database and table:

```sql
CREATE DATABASE leaderboard;
\c leaderboard
CREATE TABLE leaderboard (
    player_id    TEXT PRIMARY KEY,
    display_name TEXT,
    total_score  INT  DEFAULT 0,
    games_played INT  DEFAULT 0
);
```

## Run locally

```bash
bal run
# Publish a match result
curl -X POST http://localhost:8090/matches/add \
  -H 'Content-Type: application/json' \
  -d '{"playerId":"p1","displayName":"Alice","score":120}'
# Read the leaderboard
curl http://localhost:8091/leaderboard/top
```

## Deploy on Devant

Deploy this integration on **Devant** as an **Event Integration**.

[![Deploy to Devant](https://openindevant.choreoapps.dev/images/DeployDevant-White.svg)](https://console.devant.dev/new?gh=wso2/integration-samples/tree/main/integrator-default-profile/event-integration/cqrs_kafka)
