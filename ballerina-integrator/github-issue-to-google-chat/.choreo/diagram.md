A(["Begin"]):::startNode
B["Receive webhook from GitHub"]:::inputNode
C{"Check if the issue has <br/> the specified labels"}:::decisionNode
D["Notify on Google Chat"]:::processNode
E(["Complete"]):::endNode

A --> B --> C 
C -- Yes --> D --> E
C -- No --> E
