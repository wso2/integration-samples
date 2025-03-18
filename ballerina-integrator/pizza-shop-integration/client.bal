import ballerina/http;
import ballerinax/ai.agent;

final http:Client pizzaClient = check new ("http://localhost:8080/v1");

# Retrieves all available pizzas.
#
# + return - Array of pizzas or error
@agent:Tool
@display {
    label: "",
    iconPath: ""
}
isolated function getPizzas() returns Pizza[]|error {
    Pizza[] pizzas = check pizzaClient->/pizzas;
    return pizzas;
}

# Creates a new order.
#
# + orderRequest - The order details
# + return - Created order or error
@agent:Tool
@display {
    label: "",
    iconPath: ""
}
isolated function createOrder(OrderRequest orderRequest) returns Order|error {
    Order 'order = check pizzaClient->/orders.post(orderRequest);
    return 'order;
}

# Retrieves all orders with optional customer filter.
#
# + customerId - Optional customer ID to filter orders
# + return - Array of orders or error
@agent:Tool
@display {
    label: "",
    iconPath: ""
}
isolated function getOrders(string? customerId = ()) returns Order[]|error {
    Order[] orders;
    if customerId is string {
        orders = check pizzaClient->/orders(customerId = customerId);
    } else {
        orders = check pizzaClient->/orders;
    }
    return orders;
}

# Retrieves a specific order by ID.
#
# + orderId - ID of the order to retrieve
# + return - Order details or error
@agent:Tool
@display {
    label: "",
    iconPath: ""
}
isolated function getOrder(string orderId) returns Order|error {
    Order 'order = check pizzaClient->/orders/[orderId];
    return 'order;
}

# Updates the status of an order.
#
# + orderId - ID of the order to update
# + orderUpdate - New status for the order
# + return - Updated order or error
@agent:Tool
@display {
    label: "",
    iconPath: ""
}
isolated function updateOrder(string orderId, OrderUpdate orderUpdate) returns Order|error {
    Order updatedOrder = check pizzaClient->/orders/[orderId].patch(orderUpdate);
    return updatedOrder;
}
