INSERT INTO customers ("name", "email") VALUES
    ('Alice Johnson',  'alice@example.com'),
    ('Bob Martinez',   'bob@example.com'),
    ('Carol Nguyen',   'carol@example.com'),
    ('David Okafor',   'david@example.com');

INSERT INTO products ("sku", "name", "price", "stock") VALUES
    ('SKU-001', 'Wireless Mouse',       25.99, 120),
    ('SKU-002', 'Mechanical Keyboard',  89.50,  45),
    ('SKU-003', '27" Monitor',         329.00,  18),
    ('SKU-004', 'USB-C Hub',            39.95,  80),
    ('SKU-005', 'Laptop Stand',         49.00,  60);

INSERT INTO orders ("customerId", "status", "total") VALUES
    (1, 'paid',     115.49),
    (2, 'pending',  329.00),
    (3, 'shipped',   64.94);

INSERT INTO order_items ("orderId", "productId", "quantity", "unitPrice") VALUES
    (1, 1, 1, 25.99),
    (1, 2, 1, 89.50),
    (2, 3, 1, 329.00),
    (3, 4, 1, 39.95),
    (3, 1, 1, 24.99);
