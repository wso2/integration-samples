    A(["Start"]):::startNode
    B["Listen to Salesforce Opportunity Change Events"]:::processNode
    C{"Is Event <br/> onUpdate?"}:::decisionNode
    D["Extract Opportunity ID from Event"]:::processNode
    E["Retrieve Opportunity Details from Salesforce"]:::processNode
    F{"Is Stage <br/> 'Closed Won'?"}:::decisionNode
    G{"Meets Minimum <br/> Deal Value?"}:::decisionNode
    H["Validate Opportunity Data"]:::processNode
    I["Retrieve Contact Based on Signer Role"]:::processNode
    J{"Contact <br/> Found?"}:::decisionNode
    K["Fallback to Primary Contact"]:::processNode
    L["Validate Contact Data"]:::processNode
    M["Select DocuSign Template by Opportunity Type"]:::processNode
    N["Build Pre-filled Fields from Opportunity"]:::processNode
    O["Create DocuSign Envelope with Template"]:::processNode
    P["Add Signer and CC Recipients"]:::processNode
    Q["Send DocuSign Envelope"]:::processNode
    R{"Envelope <br/> Created?"}:::decisionNode
    S["Update Opportunity Stage to 'Contract Sent'"]:::processNode
    T["Log Success with Envelope ID"]:::processNode
    U["Log Error"]:::processNode
    V(["End"]):::endNode
    W(["End"]):::endNode

    A --> B
    B --> C
    C -- Yes --> D
    C -- No --> V
    D --> E
    E --> F
    F -- Yes --> G
    F -- No --> V
    G -- Yes --> H
    G -- No --> V
    H --> I
    I --> J
    J -- Yes --> L
    J -- No --> K
    K --> L
    L --> M
    M --> N
    N --> O
    O --> P
    P --> Q
    Q --> R
    R -- Success --> S
    R -- Failure --> U
    S --> T
    T --> W
    U --> W

    classDef startNode fill:#90EE90,stroke:#333,stroke-width:2px,color:#000
    classDef endNode fill:#FFB6C1,stroke:#333,stroke-width:2px,color:#000
    classDef processNode fill:#87CEEB,stroke:#333,stroke-width:2px,color:#000
    classDef decisionNode fill:#FFD700,stroke:#333,stroke-width:2px,color:#000
```
