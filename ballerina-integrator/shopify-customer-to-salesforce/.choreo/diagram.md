A(["Begin"]):::startNode
B["Receive Shopify<br/>Webhook Event"]:::processNode
C{"create or<br/>update event?"}:::decisionNode
D{"Contact exists<br/>in Salesforce?"}:::decisionNode
E["Find or Create<br/>Salesforce Account"]:::processNode
F["Map Shopify Customer<br/>to Salesforce Contact"]:::processNode
G["Create Salesforce<br/>Contact"]:::processNode
H["Update Salesforce<br/>Contact"]:::processNode
I(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D
C -- No --> I
D -- No --> E --> F --> G --> I
D -- Yes --> F --> H --> I
