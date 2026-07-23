A(["Begin"]):::startNode
B["Receive Salesforce CDC Event"]:::processNode
C{"Event Type?"}:::decisionNode
D["Validate & Map Data"]:::processNode
E["Create Stripe Customer"]:::processNode
F["Update Stripe Customer"]:::processNode
G["Delete Stripe Customer"]:::processNode
H(["Complete"]):::endNode
    
A --> B --> C
C -- Create/Update --> D --> E --> H
C -- Delete --> G --> H
D --> F --> H
