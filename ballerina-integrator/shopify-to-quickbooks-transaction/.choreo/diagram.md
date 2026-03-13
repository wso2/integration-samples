A(["Start: Shopify Webhook Received/OrdersFulfilled"]):::startNode
B{"Is event status valid? (Should process)"}:::decisionNode
C{"Is order > minimum amount?"}:::decisionNode
D{"Does order have line items?"}:::decisionNode
E{"Is this a duplicate transaction?"}:::decisionNode
F["Validate Customer Data against QuickBooks"]:::processNode
G["Create or Lookup QuickBooks Customer"]:::processNode
H["Map Order to QuickBooks Sales Receipt/Invoice"]:::processNode
I["Create QuickBooks Transaction"]:::processNode
J{"Transaction Creation Success?"}:::decisionNode
K["Log Success Transaction ID"]:::processNode
L["Quarantine Order Event"]:::processNode
M(["End: Finish Shopify Order Event"]):::endNode

A --> B
B -- Yes --> C
B -- No --> M
C -- Yes --> D
C -- No --> M
D -- Yes --> E
D -- No --> L
E -- No --> F
E -- Yes --> M
F --> G
G --> H
H --> I
I --> J
J -- Yes --> K
J -- No --> L
K --> M
L --> M
