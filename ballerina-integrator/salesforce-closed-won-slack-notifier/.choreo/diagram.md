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

classDef startNode fill:#4B7DDA,stroke:#fff,stroke-width:0px,color:#fff;
classDef endNode fill:#4B7DDA,stroke:#fff,stroke-width:0px,color:#fff;
classDef processNode fill:#fff,stroke:#AFAFAF,stroke-width:1px,rx:5,ry:5;
classDef decisionNode fill:#FFF5E6,stroke:#FFB347,stroke-width:1px;
