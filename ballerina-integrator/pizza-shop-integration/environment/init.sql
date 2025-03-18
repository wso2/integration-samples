-- Create pizzas table to store pizza menu items
CREATE TABLE
    pizzas (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        base_price DECIMAL(10, 2) NOT NULL,
        toppings JSON NOT NULL
    );

-- Create orders table to store order information
CREATE TABLE
    orders (
        id VARCHAR(36) PRIMARY KEY,
        customer_id VARCHAR(36) NOT NULL,
        status ENUM (
            'PENDING',
            'PREPARING',
            'OUT_FOR_DELIVERY',
            'DELIVERED',
            'CANCELLED'
        ) NOT NULL,
        total_price DECIMAL(10, 2) NOT NULL
    );

-- Create order_pizzas table to store pizza items in each order
CREATE TABLE
    order_pizzas (
        order_id VARCHAR(36) NOT NULL,
        pizza_id VARCHAR(36) NOT NULL,
        quantity INT NOT NULL,
        customizations JSON NOT NULL,
        PRIMARY KEY (order_id, pizza_id),
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (pizza_id) REFERENCES pizzas (id)
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p1',
        'Margherita',
        'Fresh tomatoes, mozzarella, basil',
        12.99,
        '["tomatoes", "mozzarella", "basil"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p2',
        'Pepperoni',
        'Classic pepperoni with mozzarella',
        14.99,
        '["pepperoni", "mozzarella", "tomato sauce"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p3',
        'BBQ Chicken',
        'Grilled chicken with BBQ sauce',
        15.99,
        '["chicken", "bbq sauce", "red onions", "mozzarella"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p4',
        'Vegetarian',
        'Mixed vegetables with fresh herbs',
        13.99,
        '["mushrooms", "bell peppers", "olives", "onions", "tomatoes"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p5',
        'Hawaiian',
        'Ham and pineapple classic',
        14.99,
        '["ham", "pineapple", "mozzarella"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p6',
        'Supreme',
        'The ultimate loaded pizza',
        16.99,
        '["pepperoni", "sausage", "mushrooms", "bell peppers", "onions", "olives"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p7',
        'Buffalo Chicken',
        'Spicy buffalo chicken',
        15.99,
        '["chicken", "buffalo sauce", "red onions", "ranch"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p8',
        'Meat Lovers',
        'For serious meat enthusiasts',
        17.99,
        '["pepperoni", "sausage", "bacon", "ham", "ground beef"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p9',
        'Four Cheese',
        'Blend of premium cheeses',
        14.99,
        '["mozzarella", "cheddar", "parmesan", "gorgonzola"]'
    );

INSERT INTO
    pizzas (id, name, description, base_price, toppings)
VALUES
    (
        'p10',
        'Mediterranean',
        'Mediterranean inspired toppings',
        15.99,
        '["feta", "olives", "sun-dried tomatoes", "spinach", "red onions"]'
    );
