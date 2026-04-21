A(["Begin"]):::startNode
B["Execute Salesforce Analytics Report"]:::processNode
C{"Report<br/>Accessible?"}:::decisionNode
D["Parse Metrics & Calculate Comparisons"]:::processNode
E{"Has<br/>Metrics?"}:::decisionNode
F["Send Performance Email via Mailchimp"]:::processNode
G(["Complete"]):::endNode

A --> B --> C
C -- No/Error --> G
C -- Yes --> D --> E
E -- Yes --> F --> G
E -- No --> G
