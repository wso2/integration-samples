    A(["Begin"]):::startNode
    B["Fetch & Filter<br/>Trello Cards"]:::processNode
    C{"Matching<br/>Cards Found?"}:::decisionNode
    D["Group Cards &<br/>Generate HTML Email"]:::processNode
    E["Create & Send<br/>Mailchimp Campaign"]:::processNode
    F(["End"]):::endNode

    A --> B --> C
    C -- Yes --> D --> E --> F
    C -- No --> F