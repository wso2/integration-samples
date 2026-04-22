A(["Begin"]):::startNode 
B["Listen for Salesforce<br/>Opportunity Event"]:::processNode 
C{"Stage =<br/>Closed Won?"}:::decisionNode 
D{"Meets Minimum<br/>Amount & Filters?"}:::decisionNode 
E["Send Notification<br/>to Slack"]:::processNode 
F(["Complete"]):::endNode

A --> B 
B --> C 
C -- Yes --> D 
C -- No --> F 
D -- Yes --> E 
D -- No --> F 
E --> F 
