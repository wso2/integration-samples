
    A(["Begin"]):::startNode
    B["Receive QuickBooks Customer Webhook"]:::processNode
    C{"Customer Event Type?"}:::decisionNode
    D["Fetch & Create Salesforce Account"]:::processNode
    E["Fetch & Update Salesforce Account"]:::processNode
    F(["Complete"]):::endNode

    A --> B --> C
    C -- Create --> D --> F
    C -- Update --> E --> F
