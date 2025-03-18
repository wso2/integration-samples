import ballerina/http;
import ballerina/sql;
import ballerina/uuid;
import ballerinax/ai.agent;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client dbClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    port = dbPort
);

service /v1 on new http:Listener(8080) {

    resource function get pizzas() returns Pizza[]|error {
        return getPizzasFromDb();
    }

    resource function post orders(@http:Payload OrderRequest orderRequest) returns Order|error {
        Order newOrder = {
            id: uuid:createType1AsString(),
            customerId: orderRequest.customerId,
            status: PENDING,
            totalPrice: check getTotalPrice(orderRequest.pizzas),
            pizzas: orderRequest.pizzas
        };

        sql:ParameterizedQuery query = `INSERT INTO orders (id, customer_id, status, total_price) 
                                      VALUES (${newOrder.id}, ${newOrder.customerId}, ${newOrder.status}, ${newOrder.totalPrice})`;
        _ = check dbClient->execute(query);

        foreach OrderPizza pizza in orderRequest.pizzas {
            sql:ParameterizedQuery pizzaQuery = `INSERT INTO order_pizzas (order_id, pizza_id, quantity, customizations) 
                                               VALUES (${newOrder.id}, ${pizza.pizzaId}, ${pizza.quantity}, ${pizza.customizations.toJsonString()})`;
            _ = check dbClient->execute(pizzaQuery);
        }

        return newOrder;
    }

    resource function get orders(string? customerId) returns Order[]|error {
        sql:ParameterizedQuery query;
        if customerId is string {
            query = `SELECT * FROM orders WHERE customer_id = ${customerId}`;
        } else {
            query = `SELECT * FROM orders`;
        }
        stream<Order, sql:Error?> orderStream = dbClient->query(query);
        Order[] orders = check from Order 'order in orderStream
            select {
                id: 'order.id,
                customerId: 'order.customerId,
                status: 'order.status,
                totalPrice: 'order.totalPrice,
                pizzas: check getOrderPizzas('order.customerId)
            };
        return orders;
    }

    resource function get orders/[string orderId]() returns Order|error {
        sql:ParameterizedQuery query = `SELECT * FROM orders WHERE id = ${orderId}`;
        Order? 'order = check dbClient->queryRow(query);
        if 'order is () {
            return error("Order not found");
        }
        'order.pizzas = check getOrderPizzas('order.customerId);
        return 'order;
    }

    resource function patch orders/[string orderId](@http:Payload OrderUpdate orderUpdate) returns Order|error {
        sql:ParameterizedQuery query = `UPDATE orders SET status = ${orderUpdate.status} WHERE id = ${orderId}`;
        sql:ExecutionResult result = check dbClient->execute(query);
        if result.affectedRowCount == 0 {
            return error("Order not found");
        }

        // Query the updated order
        sql:ParameterizedQuery getQuery = `SELECT * FROM orders WHERE id = ${orderId}`;
        Order? updatedOrder = check dbClient->queryRow(getQuery);
        if updatedOrder is () {
            return error("Order not found after update");
        }
        updatedOrder.pizzas = check getOrderPizzas(updatedOrder.customerId);
        return updatedOrder;
    }
}

isolated function getOrderPizzas(string customerId) returns OrderPizza[]|error {
    sql:ParameterizedQuery query = `
        SELECT op.pizza_id, 
               COUNT(op.pizza_id) as quantity, 
               JSON_ARRAYAGG(op.customizations) as customizations
        FROM order_pizzas op
        INNER JOIN orders o ON op.order_id = o.id
        WHERE o.customer_id = ${customerId}
        GROUP BY op.pizza_id`;

    stream<OrderPizza, sql:Error?> pizzaStream = dbClient->query(query);
    OrderPizza[] orderPizzas = check from OrderPizza orderPizza in pizzaStream
        select {
            pizzaId: orderPizza.pizzaId,
            quantity: orderPizza.quantity,
            customizations: flattenJsonArray(orderPizza.customizations)
        };
    return orderPizzas;
}

isolated function flattenJsonArray(json arr, json[] result = []) returns json[] {
    if arr !is json[] {
        return result;
    }
    foreach var item in arr {
        if item is json[] {
            result.push(...flattenJsonArray(item, result));
        } else {
            result.push(item);
        }
    }
    return result;
}

isolated function getTotalPrice(OrderPizza[] orderPizzas) returns decimal|error {
    decimal totalPrice = 0;
    Pizza[] pizzas = check getPizzasFromDb();
    foreach OrderPizza orderPizza in orderPizzas {
        Pizza? matchingPizza = getPizza(pizzas, orderPizza.pizzaId);

        if matchingPizza is Pizza {
            totalPrice += matchingPizza.basePrice * <decimal>orderPizza.quantity;
        }
    }

    return totalPrice;
}

isolated function getPizza(Pizza[] pizzas, string pizzaId) returns Pizza? {
    foreach var pizza in pizzas {
        if pizza.id == pizzaId {
            return pizza;
        }
    }
    return;
}

isolated function getPizzasFromDb() returns Pizza[]|error {
    sql:ParameterizedQuery query = `SELECT * FROM pizzas`;
    stream<Pizza, sql:Error?> pizzaStream = dbClient->query(query);
    Pizza[] pizzas = check from Pizza pizza in pizzaStream
        select pizza;
    return pizzas;
}

listener agent:Listener orderManagementAgentListener = new (listenOn = check http:getDefaultListener());

service /orderManagementAgent on orderManagementAgentListener {
    resource function post chat(@http:Payload agent:ChatReqMessage request) returns agent:ChatRespMessage|error {

        string stringResult = check _orderManagementAgentAgent->run(request.message);
        return {message: stringResult};
    }
}
