A(["Begin"]):::startNode
B["Receive Salesforce Lead <br/> Change Event"]:::processNode
C{"Is Lead <br/> Converted?"}:::decisionNode
D["Fetch Full Lead Details <br/> from Salesforce"]:::processNode
E{"Pass Filters?"}:::decisionNode
F["Fetch Owner, Account, <br/> Contact & Opportunity"]:::processNode
G["Determine Target <br/> Slack Channel"]:::processNode
H["Format Slack Message"]:::processNode
I["Send Slack Notification"]:::processNode
J(["Complete"]):::endNode

A --> B --> C
C -- Yes --> D --> E
C -- No --> J
E -- Yes --> F --> G --> H --> I --> J
E -- No --> J
