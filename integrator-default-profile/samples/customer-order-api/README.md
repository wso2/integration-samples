# Customer Order API

## Description

A minimal integration sample showing how to use a **Ballerina database persist client** from an HTTP service. The database models a small e-commerce schema (customers, products, orders, order items), and the service exposes a REST API that performs basic CRUD and a cross-entity insert via the generated persist client.

The goal is to be small enough to read end-to-end. There is no auth, pagination, OpenAPI spec, or validation beyond what the sample needs to make sense.

## What this sample demonstrates

- Defining entities with `@sql:` annotations in `persist/db/model.bal`
- Generating a typed persist client (`bal persist generate`) and using it from a Ballerina service
- Collection operations — `get`, `post`, `put`, `delete` — on the generated client
- Fetching a single record by primary key
- Filtering a collection with a `whereClause` (customers → their orders)
- Creating an `Order` first and then inserting its `OrderItem[]` rows in a follow-up call, wrapped in a single Ballerina transaction
- Reusing the generated record types directly as request/response payloads

## Prerequisites

- Ballerina 2201.13.3 or newer
- Docker (for the Postgres container) or a local Postgres 16 instance

## Usage Instructions

### 1. Start Postgres

```bash
docker compose up -d
```

This starts Postgres on `localhost:5432`, creates the `db_persist` database, runs the schema in `db/init/01_schema.sql`, and seeds sample rows from `db/init/02_seed.sql`.

### 2. Configure the DB password

Create a `Config.toml` in the sample root with the password for the bundled Postgres container:

```toml
[wso2.customer_order_api]
dbPassword = "postgres"
```

Replace `wso2` with the `org` value from your `Ballerina.toml` if you have changed it. Override `dbHost`, `dbPort`, `dbUser`, or `dbDatabase` in the same section if you are pointing at a different DB.

### 3. Run the service

```bash
bal run
```

The service listens on `http://localhost:9090/api/v1`.

### Deploy on the **WSO2 Integration Platform**

1. Deploy this integration on the **WSO2 Integration Platform** as an **Integration as API**.
2. Host a Postgres database for the application. You can create one directly on the **WSO2 Integration Platform** — in the [**Console**](https://console.devant.dev), select your **Organization** and go to the **Databases** section under the **Admin** tab.
3. Run `db/init/01_schema.sql` (and optionally `db/init/02_seed.sql`) against the database to initialize the schema and sample data.
4. In the **Overview** section of the newly created integration, configure `dbHost`, `dbPort`, `dbUser`, `dbPassword`, and `dbDatabase` before deploying.
5. Once deployed, click on **"Test"** to try out the API.

## How It Works

- The service listens on port `9090` under the `/api/v1` base path.
- On startup, a typed `persist` client is created from the entities defined in `persist/db/model.bal` and pointed at the configured Postgres instance.
- Each resource function maps directly to an operation on the generated client — for example, `GET /customers` returns `customerDb->/customers.get()`.
- Creating an order is wrapped in a Ballerina `transaction` block: the `Order` row is inserted first to obtain its primary key, then the `OrderItem[]` rows are inserted with that key and the order total (computed from current product prices) is persisted in the same commit.
- Requests for records that do not exist return `404 Not Found`; invalid order payloads (empty items, non-positive quantity, unknown customer or product) return `400 Bad Request`.

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

- Add a `GET /orders/{id}` that returns the order with its items (`OrderWithRelations`)
- Decrement `Product.stock` when an order is placed
- Add pagination via `limitClause` and `orderByClause`
- Add a scheduled job that produces a daily sales summary

## References

- [Ballerina `persist` library](https://ballerina.io/learn/persist-your-data-with-ballerina/)
- [Develop an Integration as an API](https://wso2.com/devant/docs/quick-start-guides/develop-an-integration-as-an-api/) on the WSO2 Integration Platform
