    A(["Start"]):::startNode
    B["Listen to Salesforce Opportunity Events"]:::processNode
    C{"Is 'Closed Won'?"}:::decisionNode
    D["Retrieve Opportunity & Contact Details"]:::processNode
    E["Send DocuSign Envelope"]:::processNode
    F{"Envelope <br/> Created?"}:::decisionNode
    G["Update Stage to 'Contract Sent'"]:::processNode
    H["Log Error"]:::processNode
    I(["End"]):::endNode

    A --> B
    B --> C
    C -- Yes --> D
    C -- No --> I
    D --> E
    E --> F
    F -- Yes --> G
    F -- No --> H
    G --> I
    H --> I
