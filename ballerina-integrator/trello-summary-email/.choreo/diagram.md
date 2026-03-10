flowchart TD
    A(["Begin"]):::startNode
    B["Fetch Cards from <br/>Trello Boards & Lists"]:::processNode
    C{"Are there Cards?"}:::decisionNode
    D["Apply Filters<br/>(Labels / Members / Due Date)"]:::processNode
    E{"Cards remaining<br/>after filtering?"}:::decisionNode
    F["Group Cards<br/>(by List / Member / Label)"]:::processNode
    G["Generate HTML<br/>Email Content"]:::processNode
    H["Create Mailchimp<br/>Email Campaign"]:::processNode
    I["Send Campaign to<br/>Mailchimp Audience"]:::processNode
    J(["Complete"]):::endNode
    K(["Skip - No Cards"]):::endNode

    A --> B --> C
    C -- Yes --> D --> E
    C -- No --> K
    E -- Yes --> F --> G --> H --> I --> J
    E -- No --> K