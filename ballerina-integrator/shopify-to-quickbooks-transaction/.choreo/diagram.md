A(["Shopify Webhook Received"]):::startNode
B{"Valid & non-duplicate?"}:::decisionNode
C["Get or Create QB Customer"]:::processNode
D["Map Order → QB Invoice"]:::processNode
E["Create QB Transaction"]:::processNode
F(["End"]):::endNode

A --> B
B -- No --> F
B -- Yes --> C
C --> D
D --> E
E --> F
