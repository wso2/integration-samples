flowchart TD
    A(["Begin"]):::startNode
    B["GitHub PR Closed Event Received"]:::processNode
    C{"Is PR <br/> Merged?"}:::decisionNode
    D["Apply Filters<br/>(Branch, Labels, Author)"]:::processNode
    E{"Matches <br/> Filters?"}:::decisionNode
    F["Calculate PR Cycle Time"]:::processNode
    G["Build Slack Message"]:::processNode
    H["Determine Target Channel<br/>(Based on Routing Rules)"]:::processNode
    I["Send Slack Notification"]:::processNode
    J(["Complete"]):::endNode

    A --> B
    B --> C
    C -->|Yes| D
    D --> E
    C -->|No| J
    E -->|Yes| F
    F --> G
    G --> H
    H --> I
    I --> J
    E -->|No| J
