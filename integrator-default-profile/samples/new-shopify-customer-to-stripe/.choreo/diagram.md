A(["Begin"]):::startNode
B["Receive Customer Creation Event from Shopify"]:::processNode
C["Create Customer in Stripe"]:::processNode
D(["Complete"]):::endNode

A --> B --> C --> D