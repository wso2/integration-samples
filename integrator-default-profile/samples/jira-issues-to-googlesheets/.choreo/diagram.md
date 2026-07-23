A(["Begin"]):::startNode
B["Fetch Issues from Jira"]:::processNode
C{"Are there<br/>Issues?"}:::decisionNode
D["Create Google Sheet with Timestamp"]:::processNode
E["Populate Sheet with Data"]:::processNode
F(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E --> F
C -- No --> F
