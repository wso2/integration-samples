A(["Begin"]):::startNode
B["Fetch Salesforce Opportunities"]:::processNode
C{"Are there <br/> Opportunities?"}:::decisionNode
D["Create Google Sheet with Timestamp"]:::processNode
E["Populate Google Sheet with Opportunities"]:::processNode
F(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E --> F
C -- No --> F