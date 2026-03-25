A(["Begin"]):::startNode
B["Receive Shopify Order Webhook"]:::processNode
C{"Inventory Below <br/> Threshold?"}:::decisionNode
D{"Cooldown <br/> Expired?"}:::decisionNode
E["Send SMS Alert via Twilio"]:::processNode
F(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D
C -- No --> F
D -- Yes --> E --> F
D -- No --> F
