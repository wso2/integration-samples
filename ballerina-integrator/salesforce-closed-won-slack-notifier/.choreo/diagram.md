A(["Begin"]):::startNode 
B["Listen for Salesforce Opportunity Change Event"]:::processNode 
C{"Is Stage <br/> Closed Won?"}:::decisionNode 
D{"Meets Minimum <br/> Deal Amount?"}:::decisionNode 
E{"Passes <br/> Filters?"}:::decisionNode 
F["Determine Target Slack Channel by Deal Size"]:::processNode 
G["Send to Slack with Retry Logic"]:::processNode 
H{"Message <br/> Sent?"}:::decisionNode 
J(["Complete"]):::endNode

A --> B 
B --> C 
C -- Yes --> D 
C -- No --> J 
D -- Yes --> E 
D -- No --> J 
E -- Yes --> F 
E -- No --> J 
F --> G 
G --> H 
H --> J 

