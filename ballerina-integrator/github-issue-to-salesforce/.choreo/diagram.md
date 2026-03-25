A(["Begin"]):::startNode
B["Receive GitHub Webhook Event"]:::processNode
C{"Is label in <br/> triggerLabels?"}:::decisionNode
D{"Is repository in <br/> githubRepositories?"}:::decisionNode
E["Extract Issue Details <br/> (title, body, URL)"]:::processNode
F["Create Salesforce Case <br/> with mapped fields"]:::processNode
G(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D
C -- No --> G
D -- Yes --> E --> F --> G
D -- No --> G