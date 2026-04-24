import customer_order_api.dbpersist;

import ballerina/http;
import ballerina/persist;
import ballerina/time;

service /api/v1 on new http:Listener(9090) {

    // Customers

    resource function get customers() returns dbpersist:Customer[]|error {
        return customerDb->/customers.get();
    }

    resource function get customers/[int id]() returns dbpersist:Customer|http:NotFound|error {
        dbpersist:Customer|persist:Error result = customerDb->/customers/[id].get();
        if result is persist:NotFoundError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function post customers(NewCustomer payload) returns dbpersist:Customer|error {
        int[] ids = check customerDb->/customers.post([
            {name: payload.name, email: payload.email, createdAt: time:utcNow()}
        ]);
        return customerDb->/customers/[ids[0]].get();
    }

    resource function put customers/[int id](dbpersist:CustomerUpdate payload)
            returns dbpersist:Customer|http:NotFound|error {
        dbpersist:Customer|persist:Error result = customerDb->/customers/[id].put(payload);
        if result is persist:NotFoundError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function delete customers/[int id]()
            returns dbpersist:Customer|http:NotFound|error {
        dbpersist:Customer|persist:Error result = customerDb->/customers/[id].delete();
        if result is persist:NotFoundError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function get customers/[int id]/orders() returns dbpersist:Order[]|error {
        dbpersist:Order[] orders = check customerDb->/orders.get(whereClause = `"customerId" = ${id}`);
        return orders;
    }

    // Products

    resource function get products() returns dbpersist:Product[]|error {
        return customerDb->/products.get();
    }

    // Orders

    resource function post orders(NewOrder payload)
            returns dbpersist:Order|http:BadRequest|error {
        if payload.items.length() == 0 {
            return <http:BadRequest>{body: "order must contain at least one item"};
        }
        foreach NewOrderItem item in payload.items {
            if item.quantity <= 0 {
                return <http:BadRequest>{
                    body: string `item quantity must be positive (productId=${item.productId}, quantity=${item.quantity})`
                };
            }
        }

        dbpersist:Customer|persist:Error customer = customerDb->/customers/[payload.customerId].get();
        if customer is persist:NotFoundError {
            return <http:BadRequest>{body: string `customer ${payload.customerId} not found`};
        }
        if customer is persist:Error {
            return customer;
        }

        decimal total = 0;
        dbpersist:OrderItemInsert[] itemInserts = [];
        foreach NewOrderItem item in payload.items {
            dbpersist:Product|persist:Error product = customerDb->/products/[item.productId].get();
            if product is persist:NotFoundError {
                return <http:BadRequest>{body: string `product ${item.productId} not found`};
            }
            if product is persist:Error {
                return product;
            }
            total += product.price * <decimal>item.quantity;
            itemInserts.push({
                orderId: 0,
                productId: product.id,
                quantity: item.quantity,
                unitPrice: product.price
            });
        }

        int createdOrderId = 0;
        transaction {
            int[] orderIds = check customerDb->/orders.post([
                {
                    customerId: payload.customerId,
                    status: payload.status ?: "pending",
                    total: total,
                    createdAt: time:utcNow()
                }
            ]);
            createdOrderId = orderIds[0];

            foreach int i in 0 ..< itemInserts.length() {
                itemInserts[i].orderId = createdOrderId;
            }
            _ = check customerDb->/orderitems.post(itemInserts);

            check commit;
        } on fail error e {
            return e;
        }

        dbpersist:Order created = check customerDb->/orders/[createdOrderId].get();
        return created;
    }
}

public type NewCustomer record {|
    string name;
    string email;
|};

public type NewOrderItem record {|
    int productId;
    int quantity;
|};

public type NewOrder record {|
    int customerId;
    string status?;
    NewOrderItem[] items;
|};
