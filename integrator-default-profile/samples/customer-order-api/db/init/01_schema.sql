CREATE TABLE IF NOT EXISTS customers (
    "id"         SERIAL PRIMARY KEY,
    "name"       VARCHAR(120) NOT NULL,
    "email"      VARCHAR(160) NOT NULL UNIQUE,
    "createdAt"  TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    "id"     SERIAL PRIMARY KEY,
    "sku"    VARCHAR(60)  NOT NULL UNIQUE,
    "name"   VARCHAR(160) NOT NULL,
    "price"  DECIMAL(10,2) NOT NULL CHECK ("price" >= 0),
    "stock"  INT          NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS orders (
    "id"          SERIAL PRIMARY KEY,
    "customerId"  INT NOT NULL REFERENCES customers("id") ON DELETE CASCADE,
    "status"      VARCHAR(20) NOT NULL DEFAULT 'pending',
    "total"       DECIMAL(10,2) NOT NULL DEFAULT 0,
    "createdAt"   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    "id"         SERIAL PRIMARY KEY,
    "orderId"    INT NOT NULL REFERENCES orders("id") ON DELETE CASCADE,
    "productId"  INT NOT NULL REFERENCES products("id"),
    "quantity"   INT NOT NULL CHECK ("quantity" > 0),
    "unitPrice"  DECIMAL(10,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders("customerId");
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items("orderId");
