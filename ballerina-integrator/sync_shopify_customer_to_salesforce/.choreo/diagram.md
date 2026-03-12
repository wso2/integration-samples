flowchart TD
    A(["Begin"]):::startNode
    B["Receive Shopify\nWebhook Event"]:::processNode
    C{"create or\nupdate event?"}:::decisionNode
    D{"Contact exists\nin Salesforce?"}:::decisionNode
    E["Find or Create\nSalesforce Account"]:::processNode
    F["Map Shopify Customer\nto Salesforce Contact"]:::processNode
    G["Create Salesforce\nContact"]:::processNode
    H["Update Salesforce\nContact"]:::processNode
    I(["Complete"]):::endNode

    A --> B --> C
    C -- Yes --> D
    C -- No --> I
    D -- No --> E --> F --> G --> I
    D -- Yes --> F --> H --> I
