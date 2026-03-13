A(["Begin"]):::startNode
B["Fetch Salesforce Leads"]:::processNode
C{"Are there Leads?"}:::decisionNode
D["Resolve Target Spreadsheet"]:::processNode
E["Sync Leads to Google Sheet"]:::processNode
F(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E --> F
C -- No --> F