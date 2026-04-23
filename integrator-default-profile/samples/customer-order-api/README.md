# Customer Order API

A minimal integration sample showing how to use a **Ballerina database persist client** from an HTTP service. The database models a small e-commerce schema (customers, products, orders, order items), and the service exposes a REST API that performs basic CRUD and a cross-entity insert via the generated persist client.

The goal is to be small enough to read end-to-end. There is no auth, pagination, OpenAPI spec, or validation beyond what the sample needs to make sense.

## What this sample demonstrates

- Defining entities with `@sql:` annotations in `persist/db/model.bal`
- Generating a typed persist client (`bal persist generate`) and using it from a Ballerina service
- Collection operations — `get`, `post`, `put`, `delete` — on the generated client
- Fetching a single record by primary key
- Filtering a collection with a `whereClause` (customers → their orders)
- Inserting a parent row and child rows together (`Order` + `OrderItem[]`)
- Reusing the generated record types directly as request/response payloads

## Prerequisites

- Ballerina 2201.13.3 or newer
- Docker (for the Postgres container) or a local Postgres 16 instance

## Setup

### 1. Start Postgres

```bash
docker compose up -d
```

This starts Postgres on `localhost:5432`, creates the `db_persist` database, runs the schema in `db/init/01_schema.sql`, and seeds sample rows from `db/init/02_seed.sql`.

### 2. Configure the DB password

`Config.toml` already sets the password for the bundled Postgres container:

```toml
[danniles.customer_order_api]
dbPassword = "postgres"
```

Override `dbHost`, `dbPort`, `dbUser`, or `dbDatabase` there if you are pointing at a different DB.

### 3. Run the service

```bash
bal run
```

The service listens on `http://localhost:9090/api/v1`.

## API

All endpoints are under `/api/v1`.

### Customers

```bash
# List
curl http://localhost:9090/api/v1/customers

# Get one
curl http://localhost:9090/api/v1/customers/1

# Create
curl -X POST http://localhost:9090/api/v1/customers \
  -H 'Content-Type: application/json' \
  -d '{"name": "Eve Patel", "email": "eve@example.com"}'

# Update (any subset of fields)
curl -X PUT http://localhost:9090/api/v1/customers/1 \
  -H 'Content-Type: application/json' \
  -d '{"name": "Alice J."}'

# Delete
curl -X DELETE http://localhost:9090/api/v1/customers/1

# Orders for a customer
curl http://localhost:9090/api/v1/customers/1/orders
```

### Products

```bash
curl http://localhost:9090/api/v1/products
```

### Orders

Create an order with one or more line items. The service looks up each product, uses its current price as the unit price, and computes the order total.

```bash
curl -X POST http://localhost:9090/api/v1/orders \
  -H 'Content-Type: application/json' \
  -d '{
        "customerId": 1,
        "status": "pending",
        "items": [
          {"productId": 1, "quantity": 2},
          {"productId": 4, "quantity": 1}
        ]
      }'
```

`status` is optional and defaults to `"pending"`.

## Regenerating the persist client

If you edit `persist/db/model.bal`, regenerate the client:

```bash
bal persist generate
```

`bal build` also runs this automatically.

## Ideas to extend this sample

- Wrap `POST /orders` in a persist transaction so the order and its items commit atomically
- Add a `GET /orders/{id}` that returns the order with its items (`OrderWithRelations`)
- Decrement `Product.stock` when an order is placed
- Add pagination via `limitClause` and `orderByClause`
- Add a scheduled job that produces a daily sales summary
