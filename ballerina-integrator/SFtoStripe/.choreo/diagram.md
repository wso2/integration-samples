graph TD
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
    
    classDef startNode fill:#90EE90,stroke:#228B22,stroke-width:2px,color:#000
    classDef endNode fill:#FFB6C6,stroke:#DC143C,stroke-width:2px,color:#000
    classDef processNode fill:#87CEEB,stroke:#4682B4,stroke-width:2px,color:#000
    classDef decisionNode fill:#FFD700,stroke:#FF8C00,stroke-width:2px,color:#000


