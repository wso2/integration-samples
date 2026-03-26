A(["Begin"]):::startNode
B["Receive Order Creation Event from Shopify"]:::processNode
C{"Valid & non-duplicate?"}:::decisionNode
D["Get or Create QB Customer"]:::processNode
E["Map Order → QB Invoice"]:::processNode
F["Create QB Transaction"]:::processNode
G(["End"]):::endNode

A --> B
B --> C
C -- No --> G
C -- Yes --> D
D --> E
E --> F
F --> G
